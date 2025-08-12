import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      ),
      body: Center(
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
                  // You can add more details here, like category, location, etc.
                ));
              },
            );
          },
        ),
      ),
    );
  }
}