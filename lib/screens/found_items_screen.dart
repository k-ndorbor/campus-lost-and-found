import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/item.dart';


class FoundItemsScreen extends StatelessWidget {
  const FoundItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Found Items'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/'); // Navigate back to the home screen
          },
        ),
 backgroundColor: const Color(0xFF3b436b), // Dark blue background for AppBar
      ),
      backgroundColor: const Color(0xFF3b436b), // Dark blue background for the screen
      body: Center(
        child: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
 focusNode: FocusNode(), // Added to prevent keyboard from showing immediately
              decoration: InputDecoration(
                hintText: 'Search by filter',
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
 borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none, // No border
                ),
 filled: true,
                fillColor: const Color(0xFF5c638b), // Slightly lighter blue for search bar
                hintStyle: const TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
 Expanded(
 child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('items')
              .where('isLost', isEqualTo: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No found items yet.');
            }

            final foundItems = snapshot.data!.docs.map((doc) {
              return Item.fromFirestore(doc);
            }).toList();

            return ListView.builder(
              itemCount: foundItems.length,
              itemBuilder: (context, index) {
                final item = foundItems[index];
 return InkWell(
 onTap: () {
 context.go('/items/${item.id}');
 },
                  child: ListTile(
 leading: item.imageUrl != null
 ? SizedBox(
 width: 50,
 height: 50,
 child: CachedNetworkImage( 
 imageUrl: item.imageUrl,
 placeholder: (context, url) =>
 CircularProgressIndicator(),
 errorWidget: (context, url, error) => Icon(Icons.error),
 fit: BoxFit.cover,
 color: Colors.grey,
                          ),
                        )
                      : Icon(Icons.image),
                  title: Text(item.name),
                  subtitle: Text(item.description),
 trailing: Column(
 crossAxisAlignment: CrossAxisAlignment.end,
 children: [
 Text('Location: ${item.location}'),
 Text('Date: ${item.date}'),
 ],
 ),
                ));
              },
            );
          },
        ),
      ),
    );
  }
}