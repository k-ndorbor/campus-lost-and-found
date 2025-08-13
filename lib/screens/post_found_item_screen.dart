import 'package:flutter/material.dart';

class PostFoundItemScreen extends StatefulWidget {
  const PostFoundItemScreen({super.key});

  @override
  State<PostFoundItemScreen> createState() => _PostFoundItemScreenState();
}

class _PostFoundItemScreenState extends State<PostFoundItemScreen> {
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _currentLocationController = TextEditingController();
  final _dateFoundController = TextEditingController();
  final _colourController = TextEditingController();

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _currentLocationController.dispose();
    _dateFoundController.dispose();
    _colourController.dispose();
    super.dispose();
  }

  void _submitItem() {
    // TODO: Implement submission logic
    print('Submitting item:');
    print('Item Name: ${_itemNameController.text}');
    print('Description: ${_descriptionController.text}');
    print('Current Location: ${_currentLocationController.text}');
    print('Date Found: ${_dateFoundController.text}');
    print('Colour: ${_colourController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E), // Dark blue background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        title: const Text(
          'Post found item',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3949AB), // Lighter blue
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, size: 40, color: Colors.white),
                    onPressed: () {
                      // TODO: Implement image picking
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _itemNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'item name',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  filled: true,
                  fillColor: const Color(0xFF3949AB), // Lighter blue
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  filled: true,
                  fillColor: const Color(0xFF3949AB), // Lighter blue
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                maxLines: null,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _currentLocationController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Current location',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  filled: true,
                  fillColor: const Color(0xFF3949AB), // Lighter blue
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _dateFoundController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Date found',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  filled: true,
                  fillColor: const Color(0xFF3949AB), // Lighter blue
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _colourController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Colour',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  filled: true,
                  fillColor: const Color(0xFF3949AB), // Lighter blue
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700), // Gold color
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black, // Assuming black text on gold button
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}