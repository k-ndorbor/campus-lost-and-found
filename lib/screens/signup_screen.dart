import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

final _logger = Logger('SignupScreen');

enum UserType { student, admin }

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  UserType? _selectedUserType = UserType.student;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      _logger.warning('Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      _logger.info('Attempting to create user with email: $email');
      
      // 1. First, create the user in Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'Failed to create user in Firebase Authentication',
        );
      }

      _logger.info('User created in Firebase Auth: ${user.uid}');

      // 2. Prepare user data for Firestore
      final userData = {
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'email': email,
        'phone': _phoneController.text.trim(),
        'userType': _selectedUserType.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
      };
      
      _logger.info('Saving user data to Firestore: $userData');
      
      // 3. Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      _logger.info('User data saved to Firestore successfully');

      // 4. Send email verification
      await user.sendEmailVerification();
      _logger.info('Verification email sent to $email');

      if (!mounted) {
        _logger.warning('Widget not mounted, cannot navigate');
        return;
      }

      // 5. Navigate to home screen
      _logger.info('Navigating to home screen');
      if (context.mounted) {
        context.go('/');
        _logger.info('Navigation to home complete');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred during signup. Please try again.';
      
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists for this email address.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          message = 'The password is too weak. Please choose a stronger password.';
          break;
        default:
          message = 'Authentication error: ${e.message}';
      }
      
      _logger.severe('Firebase Auth Error (${e.code}): ${e.message}');
      
      if (mounted) {
        setState(() {
          _errorMessage = message;
          _isLoading = false;
        });
      }
    } on FirebaseException catch (e) {
      _logger.severe('Firestore Error (${e.code}): ${e.message}');
      
      // If we got here, the user was created in Auth but Firestore failed
      // Try to delete the auth user to prevent orphaned accounts
      try {
        await _auth.currentUser?.delete();
        _logger.info('Rolled back user creation in Auth due to Firestore failure');
      } catch (deleteError) {
        _logger.severe('Failed to rollback user creation: $deleteError');
      }
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to set up your account. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      _logger.severe('Unexpected error during signup', e, stackTrace);
      
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
          _isLoading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set up logging
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF0A185A), // Dark blue background
      body: Stack(
        children: [
          // Bottom left wave image
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              'assets/Group 2.png',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          // Top right wave image
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              'assets/Group 3.png',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          // Main content with SingleChildScrollView
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 80),
                const Text(
                  'Hi Welcome!',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Create an Account',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 15),
                      _buildUserTypeDropdown(),
                      if (_errorMessage != null) ...{
                        const SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      },
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBackgroundColor: Colors.yellow.withOpacity(0.7),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xFF0A185A),
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF0A185A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.arrow_forward,
                                color: Color(0xFF0A185A),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to login screen using GoRouter
                        GoRouter.of(context).go('/login');
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(color: Colors.yellow),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20), // Add some bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: const Color(0xFF1F2E4D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.yellow),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.yellow),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.yellow, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.orange),
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildUserTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2E4D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.yellow),
      ),
      child: DropdownButtonFormField<UserType>(
        value: _selectedUserType,
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: 'Sign up as',
          labelStyle: TextStyle(color: Colors.white),
        ),
        dropdownColor: const Color(0xFF1F2E4D),
        style: const TextStyle(color: Colors.white),
        iconEnabledColor: Colors.white,
        items: UserType.values.map((type) {
          return DropdownMenuItem<UserType>(
            value: type,
            child: Text(
              type.toString().split('.').last[0].toUpperCase() + 
              type.toString().split('.').last.substring(1),
            ),
          );
        }).toList(),
        onChanged: _isLoading 
            ? null 
            : (UserType? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedUserType = newValue;
                  });
                }
              },
      ),
    );
  }
}
