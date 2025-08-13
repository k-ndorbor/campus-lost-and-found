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
    'assets/academics_ads.png',
    'assets/academics_ads (1).png',
    'assets/academics_ads (2).png',
    'assets/Mask group.png',
  ];

  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Total duration for the animation
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_currentImageIndex < _splashImages.length - 1) {
          setState(() {
            _currentImageIndex++;
          });
          _controller.forward(from: 0.0); // Restart animation for the next image
        } else {
          // Animation complete, navigate to login or home
          if (mounted) {
             final user = FirebaseAuth.instance.currentUser;
             if (user != null) {
               context.go('/'); // Navigate to home if already logged in
             } else {
               context.go('/login'); // Navigate to login if not logged in
             }
          }
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
      backgroundColor: const Color(0xFF3b436b), // Match the design background
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
                    const Text(
                      'CLF',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Adjust color as needed
                      ),
                    ),
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