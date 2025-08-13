import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  _AnimatedSplashScreenState createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<String> _splashImages = [
    'assets/academicons_ads.png',
    'assets/academicons_ads (1).png',
    'assets/academicons_ads (2).png',
    'assets/Group 4.png',
  ];

  int _currentImageIndex = 0;

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Wait for Firebase to initialize if needed
      await Firebase.initializeApp();

      // Check if user is logged in
      final user = FirebaseAuth.instance.currentUser;

      if (mounted) {
        if (user != null) {
          // User is logged in, navigate to home screen
          if (context.mounted) {
            context.go('/home');
          }
        } else {
          // User is not logged in, navigate to login screen
          if (context.mounted) {
            context.go('/login');
          }
        }
      }
    } catch (e) {
      // If there's an error (e.g., Firebase not initialized), go to login
      if (mounted && context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
          milliseconds: 1500), // Reduced from 3 seconds to 1.5 seconds
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        if (_currentImageIndex < _splashImages.length - 1) {
          if (mounted) {
            setState(() {
              _currentImageIndex++;
            });
          }
          _controller.forward(
              from: 0.0); // Restart animation for the next image
        } else {
          // Animation complete, check auth and navigate
          await _checkAuthAndNavigate();
        }
      }
    });

    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E), // Match the design background
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: _currentImageIndex == _splashImages.length - 1
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      _splashImages[_currentImageIndex],
                      width: 100, // Adjust size as needed
                      height: 100, // Adjust size as needed
                    ),
                    const SizedBox(width: 10),
                    // const Text(
                    //   '',
                    //   style: TextStyle(
                    //     fontSize: 40,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.white, // Adjust color as needed
                    //   ),
                    // ),
                  ],
                )
              : Image.asset(
                  _splashImages[_currentImageIndex],
                  width: 150, // Adjust size as needed
                  height: 150, // Adjust size as needed
                ),
        ),
      ),
    );
  }
}
