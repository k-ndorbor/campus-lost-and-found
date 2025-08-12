import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

final _logger = Logger('LoginScreen');

// Helper function to log messages
void _logInfo(String message) {
  if (kDebugMode) {
    print('LOGIN_SCREEN: $message');
  }
  _logger.info(message);
}

void _logError(String message, [dynamic error, StackTrace? stackTrace]) {
  if (kDebugMode) {
    print('LOGIN_SCREEN ERROR: $message');
    if (error != null) {
      print('Error: $error');
    }
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }
  _logger.severe(message, error, stackTrace);
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          // Main content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 80.0),
                const Text(
                  'Hi\nWelcome!',
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40.0),
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 40.0,
                          color: Color(0xFF0A185A),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40.0),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFFFFD700),
                          width: 2.0), // Yellow border
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFFFFD700),
                          width: 2.0), // Yellow border
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFFFFD700),
                          width: 2.0), // Yellow border
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFFFFD700),
                          width: 2.0), // Yellow border
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: _login,
                    child: const Icon(Icons.arrow_forward,
                        color: Color(0xFFFFD700),
                        size: 40.0), // Yellow arrow icon
                  ),
                ),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    // Navigate to signup screen using GoRouter
                    GoRouter.of(context).go('/signup');
                  },
                  child: const Text('Don\'t have an account? Sign up',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter both email and password')),
        );
      }
      return;
    }

    _logInfo('Attempting login with email: ${_emailController.text.trim()}');

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _logInfo('Login successful for user: ${userCredential.user?.uid}');

      if (!mounted) {
        _logError('Widget not mounted, not navigating');
        return;
      }

      _logInfo('Navigating to home screen');
      context.go('/');
      _logInfo('Navigation to home complete');

    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred during login';

      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
          message = 'Invalid email or password';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        case 'too-many-requests':
          message = 'Too many login attempts. Please try again later.';
          break;
        default:
          message = 'Login failed: ${e.message}';
      }

      _logError('Login failed', e);

      if (mounted) {
        _showErrorDialog(message);
      }
    } catch (e, stackTrace) {
      _logError('Unexpected error during login', e, stackTrace);

      if (mounted) {
        _showErrorDialog('An unexpected error occurred. Please try again.');
      }
    }
  }

  // Helper method to show error dialog
  void _showErrorDialog(String message) {
    if (!mounted) {
      _logError('Cannot show error dialog - widget not mounted');
      return;
    }
    
    _logInfo('Showing error dialog: $message');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
