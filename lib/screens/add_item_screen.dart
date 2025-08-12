import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // Assuming you'll use image_picker
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'dart:io';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isLost = true; // Default to lost item
  XFile? _pickedImage;

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<String?> _uploadImageToCloudinary(XFile image) async {
    // Replace with your Cloudinary cloud name and upload preset
    const String cloudName = 'YOUR_CLOUD_NAME';
    // IMPORTANT: Using unsigned uploads is not recommended for production due to security risks.
    const String uploadPreset = 'YOUR_UPLOAD_PRESET';
    final cloudinary = Cloudinary.basic(cloudName: cloudName);

    // Read the image file as bytes
    final byteData = await image.readAsBytes();
    final Uint8List imageBytes = byteData.buffer.asUint8List();

    try {
      final resource = CloudinaryUploadResource(fileBytes: imageBytes, uploadPreset: uploadPreset);
      final response = await cloudinary.uploadResource(resource);
      return response.secureUrl; // Assuming secureUrl is still the correct property for the URL
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      return null;
    }
  }
  void _submitForm() async {
    if (_formKey.currentState!.validate() && FirebaseAuth.instance.currentUser != null) {
      String imageUrl = ''; // Placeholder for image URL

      if (_pickedImage != null) {
        final uploadedImageUrl = await _uploadImageToCloudinary(_pickedImage!);
        if (uploadedImageUrl != null) {
          imageUrl = uploadedImageUrl;
        }
      }

      await FirebaseFirestore.instance.collection('items').add({
        'name': _itemNameController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'contact': _contactController.text,
        'isLost': _isLost,
        'imageUrl': imageUrl, // Save image URL
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item Added Successfully!')),
        );
        // Clear the form after successful submission
        _itemNameController.clear();
        _descriptionController.clear();
        _categoryController.clear();
        _locationController.clear();
        _pickedImage = null; // Clear picked image after submission
        _contactController.clear();
        setState(() {
          _isLost = true; // Reset toggle
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add item: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Information'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact information';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Item Type:'),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Lost'),
                    selected: _isLost,
                    onSelected: (selected) {
                      setState(() {
                        _isLost = selected;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Found'),
                    selected: !_isLost,
                    onSelected: (selected) {
                      setState(() {
                        _isLost = !selected;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    _pickedImage = image;
                  });                },

                icon: const Icon(Icons.camera_alt),
                label: const Text('Add Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}