import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:path/path.dart' as path;
import '../models/item.dart';
import '../services/item_service.dart';

// Initialize Cloudinary
final cloudinary = Cloudinary.full(
  apiKey: '683444523538964',
  apiSecret: 'F0CGUn3C3OSkarKaRQOx2bjN2rA',
  cloudName: 'diove2py3',
);

class ReportLostItemScreen extends StatefulWidget {
  const ReportLostItemScreen({super.key});

  @override
  _ReportLostItemScreenState createState() => _ReportLostItemScreenState();
}

class _ReportLostItemScreenState extends State<ReportLostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _colorController = TextEditingController();
  final _categoryController = TextEditingController();
  final _contactController = TextEditingController();

  final ItemService _itemService = ItemService();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(DateTime.now());
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _colorController.dispose();
    _categoryController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Failed to pick image');
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    try {
      setState(() => _isLoading = true);

      final fileName =
          'lost_${DateTime.now().millisecondsSinceEpoch}${path.extension(_imageFile!.path)}';

      final response = await cloudinary.uploadResource(
        CloudinaryUploadResource(
          filePath: _imageFile!.path,
          resourceType: CloudinaryResourceType.image,
          folder: 'campus_lost_and_found',
          fileName: fileName,
        ),
      );

      if (response.isSuccessful && response.secureUrl != null) {
        return response.secureUrl;
      } else {
        throw Exception(
            'Failed to upload image to Cloudinary: ${response.error}');
      }
    } catch (e) {
      _showError('Failed to upload image: $e');
      return null;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _uploadImage();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final item = Item(
        id: '',
        name: _itemNameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        location: _locationController.text.trim(),
        imageUrl: imageUrl ?? '',
        contact: _contactController.text.trim(),
        isLost: true,
        date: _dateController.text.trim(),
        color: _colorController.text.trim(),
        userId: user.uid,
        createdAt: DateTime.now(),
        status: 'lost',
      );

      await _itemService.addItem(item);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lost item reported successfully!')),
        );
        context.go('/lost-items');
      }
    } catch (e) {
      _showError('Failed to report lost item: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      appBar: AppBar(
        title: const Text('Report Lost Item',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Image Picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3949AB),
                          borderRadius: BorderRadius.circular(10),
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _imageFile == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate,
                                      size: 40, color: Colors.white70),
                                  SizedBox(height: 8),
                                  Text('Add Photo',
                                      style: TextStyle(color: Colors.white70)),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form Fields
                    _buildTextField(_itemNameController, 'Item Name'),
                    const SizedBox(height: 10),
                    _buildTextField(_categoryController, 'Category'),
                    const SizedBox(height: 10),
                    _buildTextField(_descriptionController, 'Description',
                        maxLines: 3),
                    const SizedBox(height: 10),
                    _buildTextField(_locationController, 'Location Lost'),
                    const SizedBox(height: 10),
                    _buildDateField(),
                    const SizedBox(height: 10),
                    _buildTextField(_colorController, 'Color'),
                    const SizedBox(height: 10),
                    _buildTextField(_contactController, 'Your Contact Info'),
                    const SizedBox(height: 25),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Text(
                              'Report Lost Item',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF3949AB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter $label' : null,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      style: const TextStyle(color: Colors.white),
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: 'Date Lost',
        hintText: 'Tap to select date',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF3949AB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon:
            const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
        suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please select date' : null,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1A237E),
              onPrimary: Colors.white,
              surface: Color(0xFF3949AB),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = _formatDate(picked);
      });
    }
  }
}
