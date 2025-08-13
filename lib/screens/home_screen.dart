import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      color: const Color(0xFF1A237E), // Match background color
      elevation: 0.0, // Remove elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to item detail screen
          context.go('/items/${item.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Placeholder for user profile picture
                  CircleAvatar(
                    backgroundColor: Colors.blueGrey[700],
                    child: const Icon(Icons.person, color: Colors.white),
                    radius: 20,
                  ),
                  const SizedBox(width: 8),
                  // Placeholder for user name
                  const Text(
                    'Elizabeth Lawson', // Replace with actual user name if available
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Item Image
              if (item.imageUrl.isNotEmpty)
                Container(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
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
              const SizedBox(height: 16),
              _buildInfoText('Item name: ${item.name}'),
              _buildInfoText('Description: ${item.description}'),
              _buildInfoText(item.isLost ? 'Location lost: ${item.location}' : 'Current location: ${item.location}'),
              _buildInfoText(item.isLost ? 'Date lost: ${item.date}' : 'Date found: ${item.date}'),
              _buildInfoText('Colour: ${item.color ?? 'N/A'}'), // Assuming item has a 'color' field
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text('Campus Lost & Found'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // TODO: Implement drawer menu
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
                        foregroundColor: Colors.white, // White text
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
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
                        foregroundColor: Colors.white, // White text
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // StreamBuilder for Lost Items
              StreamBuilder<List<Item>>(
                stream: Provider.of<ItemService>(context).getItems(isLost: true),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final lostItems = snapshot.data ?? [];

                  if (lostItems.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'No recent lost items.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  // Display only the most recent lost item for the design
                  final recentLostItem = lostItems.first;
                  return _buildItemCard(recentLostItem, context);
                },
              ),
              const SizedBox(height: 24),

              // StreamBuilder for Found Items (Displaying only one for now as per design)
               StreamBuilder<List<Item>>(
                stream: Provider.of<ItemService>(context).getItems(isLost: false),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final foundItems = snapshot.data ?? [];

                  if (foundItems.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'No recent found items.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  // Display only the most recent found item for the design
                  final recentFoundItem = foundItems.first;
                  return _buildItemCard(recentFoundItem, context);

                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoText('Item name: Car keys'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor:
                            const Color(0xFFFBC02D), // Golden yellow color
                        foregroundColor: Colors.black, // Black text
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text('Messages'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}