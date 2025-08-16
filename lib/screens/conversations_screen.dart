import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/conversation.dart';

class ConversationsScreen extends StatelessWidget {
  final String currentUserId;

  const ConversationsScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Builder(
        builder: (context) {
          try {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .where('participants', arrayContains: currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Conversations error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading conversations',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.red[600],
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please try again later',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF1A237E)),
                    ),
                  );
                }

                final conversations = snapshot.data?.docs ?? [];

                if (conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conversations yet',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a conversation from an item\'s detail page',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Sort conversations by lastMessageAt in memory (more robust)
                final sortedConversations =
                    List<DocumentSnapshot>.from(conversations);
                sortedConversations.sort((a, b) {
                  try {
                    final aData = a.data() as Map<String, dynamic>?;
                    final bData = b.data() as Map<String, dynamic>?;

                    final aTime = aData?['lastMessageAt'];
                    final bTime = bData?['lastMessageAt'];

                    if (aTime == null && bTime == null) return 0;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;

                    DateTime aDateTime, bDateTime;

                    if (aTime is Timestamp) {
                      aDateTime = aTime.toDate();
                    } else if (aTime is DateTime) {
                      aDateTime = aTime;
                    } else {
                      return 1; // Put invalid dates at the end
                    }

                    if (bTime is Timestamp) {
                      bDateTime = bTime.toDate();
                    } else if (bTime is DateTime) {
                      bDateTime = bTime;
                    } else {
                      return -1; // Put invalid dates at the end
                    }

                    return bDateTime.compareTo(aDateTime); // Most recent first
                  } catch (e) {
                    return 0; // Keep original order if sorting fails
                  }
                });

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: sortedConversations.length,
                  itemBuilder: (context, index) {
                    try {
                      final conversation = Conversation.fromMap(
                        sortedConversations[index].data()
                            as Map<String, dynamic>,
                        sortedConversations[index].id,
                      );

                      // Get the other participant's ID
                      final otherUserId = conversation.participants.firstWhere(
                        (id) => id != currentUserId,
                        orElse: () => '',
                      );

                      if (otherUserId.isEmpty) {
                        return const SizedBox
                            .shrink(); // Skip invalid conversations
                      }

                      return _buildConversationTile(
                          context, conversation, otherUserId);
                    } catch (e) {
                      print('Error parsing conversation: $e');
                      return const SizedBox
                          .shrink(); // Skip problematic conversations
                    }
                  },
                );
              },
            );
          } catch (e) {
            print('Unexpected error in conversations screen: $e');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unexpected error',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.red[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please restart the app',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildConversationTile(
      BuildContext context, Conversation conversation, String otherUserId) {
    final lastMessageTime =
        DateFormat('h:mm a').format(conversation.lastMessageAt);
    final isUnread = !conversation.lastMessageIsRead &&
        conversation.lastMessageSenderId != otherUserId;

    // Fetch user data from Firestore
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, snapshot) {
        String displayName = 'User';
        String? profileImageUrl;

        if (snapshot.hasData && snapshot.data!.exists) {
          try {
            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            displayName = userData?['name'] ??
                userData?['displayName'] ??
                userData?['email']?.toString().split('@').first ??
                'User';
            profileImageUrl = userData?['photoURL']?.toString();
          } catch (e) {
            print('Error parsing user data: $e');
            displayName = 'User';
            profileImageUrl = null;
          }
        }

        return _buildConversationTileContent(
          context,
          conversation,
          otherUserId,
          displayName,
          profileImageUrl,
          lastMessageTime,
          isUnread,
        );
      },
    );
  }

  Widget _buildConversationTileContent(
    BuildContext context,
    Conversation conversation,
    String otherUserId,
    String displayName,
    String? profileImageUrl,
    String lastMessageTime,
    bool isUnread,
  ) {
    return ListTile(
      onTap: () {
        // Navigate to the chat screen
        context.go(
          '/chat/${conversation.id}',
          extra: {
            'currentUserId': currentUserId,
            'otherUserId': otherUserId,
            'otherUserName': displayName,
            'itemId': conversation.itemId,
            'otherUserImageUrl': profileImageUrl,
          },
        );
      },
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        child: profileImageUrl != null
            ? ClipOval(
                child: Image.network(
                  profileImageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.person,
                    color: Colors.grey,
                  ),
                ),
              )
            : const Icon(Icons.person, color: Colors.grey),
      ),
      title: Text(
        displayName,
        style: TextStyle(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          color: isUnread ? Colors.black87 : Colors.grey[600],
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            lastMessageTime,
            style: TextStyle(
              fontSize: 12,
              color: isUnread ? const Color(0xFF1A237E) : Colors.grey[500],
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isUnread)
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
