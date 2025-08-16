import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/item.dart';
import '../services/item_service.dart';

class HomeScreen extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  Widget _buildItemCard(Item item, BuildContext context) {
    return Card(
      color: Colors.grey[200], // Grey background
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Badge for Lost/Found
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isLost ? Colors.red[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.isLost ? 'LOST' : 'FOUND',
                    style: TextStyle(
                      color: item.isLost ? Colors.red[800] : Colors.green[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                // Message button
                IconButton(
                  icon: const Icon(Icons.message, color: Colors.blue),
                  onPressed: () async {
                    try {
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please sign in to message')),
                          );
                          context.go('/login');
                        }
                        return;
                      }

                      // Check if user is trying to message themselves
                      if (currentUser.uid == item.userId) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('This is your own post')),
                          );
                        }
                        return;
                      }

                      // Fetch the other user's name from the users collection
                      String otherUserName = 'User';
                      try {
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(item.userId)
                            .get();

                        if (userDoc.exists) {
                          final userData =
                              userDoc.data() as Map<String, dynamic>;
                          otherUserName = userData['name'] ??
                              userData['displayName'] ??
                              'User';
                        }
                      } catch (e) {
                        // If we can't fetch the user's name, fall back to contact or default
                        otherUserName =
                            item.contact.isNotEmpty ? item.contact : 'User';
                      }

                      // Check if conversation already exists
                      final conversationQuery = await FirebaseFirestore.instance
                          .collection('conversations')
                          .where('participants', arrayContains: currentUser.uid)
                          .where('itemId', isEqualTo: item.id)
                          .limit(1)
                          .get();

                      String conversationId;

                      if (conversationQuery.docs.isNotEmpty) {
                        // Use existing conversation
                        conversationId = conversationQuery.docs.first.id;
                      } else {
                        // Create new conversation
                        final conversationRef = await FirebaseFirestore.instance
                            .collection('conversations')
                            .add({
                          'participants': [currentUser.uid, item.userId],
                          'itemId': item.id,
                          'lastMessage': '',
                          'lastMessageAt': FieldValue.serverTimestamp(),
                          'lastMessageSenderId': currentUser.uid,
                          'lastMessageIsRead': false,
                        });
                        conversationId = conversationRef.id;
                      }

                      if (context.mounted) {
                        // Navigate to chat screen
                        context.go(
                          '/chat/$conversationId',
                          extra: {
                            'currentUserId': currentUser.uid,
                            'otherUserId': item.userId,
                            'itemId': item.id,
                            'otherUserName': otherUserName,
                            'otherUserImageUrl':
                                null, // You can store and fetch user profile images
                          },
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Failed to start conversation. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  tooltip: 'Message about this item',
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Item Image
            if (item.imageUrl.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,

                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(8.0),
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.black.withOpacity(0.1),
                //       blurRadius: 4,
                //       offset: const Offset(0, 2),
                //     ),
                //   ],
                // ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            // Item Details
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  item.location,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  item.date,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          'Campus Lost & Found',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // leading: Builder(
        //   builder: (BuildContext context) {
        //     return IconButton(
        //       icon: const Icon(Icons.menu),
        //       onPressed: () {
        //         // TODO: Implement drawer menu
        //       },
        //     );
        //   },
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message_outlined, color: Colors.white),
            onPressed: () => context.go('/messages'),
            tooltip: 'Messages',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _signOut(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF1A237E),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                context.go('/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _signOut(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Found Items'),
              onTap: () {
                context.go('/found-items');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Lost Items'),
              onTap: () {
                context.go('/lost-items');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/post-found-item'),
                    icon: const Icon(Icons.add),
                    label: const Text('Post found item'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/report-lost-item'),
                    icon: const Icon(Icons.add),
                    label: const Text('Report lost item'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // StreamBuilder for All Items
            StreamBuilder<List<Item>>(
              stream: Provider.of<ItemService>(context).getAllItems(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'No items found.',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildItemCard(items[index], context),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // // Messages Button
            // ElevatedButton(
            //   onPressed: () {
            //     // Navigate to messages screen
            //   },
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(vertical: 12),
            //     backgroundColor: const Color(0xFFFBC02D), // Golden yellow color
            //     foregroundColor: Colors.black, // Black text
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8.0),
            //     ),
            //   ),
            //   child: const Text('Messages'),
            // ),
          ],
        ),
      ),
    );
  }
}
