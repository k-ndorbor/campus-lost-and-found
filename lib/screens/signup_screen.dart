import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:go_router/go_router.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0E1C36),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Yellow wave on top right
            Positioned(
              top: -100,
              right: -100,
              child: Transform.rotate(
                angle: -0.3,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              ),
            ),
            // Yellow wave on bottom left
            Positioned(
              bottom: -100,
              left: -100,
              child: Transform.rotate(
                angle: 0.3,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  _buildTextField('Name'),
                  const SizedBox(height: 15),
                  _buildTextField('Email'),
                  const SizedBox(height: 15),
                  _buildTextField('Password', obscureText: true),
                  const SizedBox(height: 15),
                  _buildTextField('Phone Number'),
                  const SizedBox(height: 15),
                  _buildDropdownField('Sign in as?'),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement sign up logic
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sign In',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
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
                          // context.go('/login');
                        },
                        child: const Text(
                          'Log In',
                          style: TextStyle(color: Colors.yellow),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTextField(String hintText, {bool obscureText = false}) {
  return TextField(
    obscureText: obscureText,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white70),
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
    ),
  );
}

Widget _buildDropdownField(String hintText) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF1F2E4D),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.yellow),
    ),
    child: DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      hint: Text(
        hintText,
        style: const TextStyle(color: Colors.white70),
      ),
      items: <String>['Option 1', 'Option 2', 'Option 3'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        // TODO: Implement dropdown logic
      },
      dropdownColor: const Color(0xFF1F2E4D),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
    ),
  );
}