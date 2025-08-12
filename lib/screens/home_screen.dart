import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const HomeScreen({super.key});

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          alignment: Alignment.centerLeft,
          builder: (BuildContext context) {
            return IconButton(icon: const Icon(Icons.menu), onPressed: () {});
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _signOut();
              if (context.mounted) {
                // Navigate to login screen and remove all other routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      backgroundColor: const Color(0xFF3b436b), // Dark blue background color
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/add-item'),
                      icon: const Icon(Icons.add),
                      label: const Text('Post found item'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/add-item'),
                      icon: const Icon(Icons.add),
                      label: const Text('Report lost item'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.blueGrey[800], // Slightly lighter dark blue for the card
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/Group 2.png'), // Placeholder
                            radius: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Elizabeth Lawson', // Placeholder
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // White text
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          'assets/Group 3.png', // Placeholder
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16), // Corrected height
                      const Text(
                        'Item name: Car keys', // Placeholder
                        style: TextStyle(fontSize: 16, color: Colors.white), // White text
                      ),
                      const SizedBox(height: 4), // Corrected height
                      const Text(
                        'Description: Black with a leather key holder', // Placeholder
                        style: TextStyle(fontSize: 16, color: Colors.white), // White text
                      ),
                      const SizedBox(height: 4), // Corrected height
                      const Text(
                        'Location lost: CSOB building', // Placeholder
                        style: TextStyle(fontSize: 16, color: Colors.white), // White text
                      ),
                      const SizedBox(height: 4), // Corrected height
                      const Text(
                        'Date lost: 06/08/25', // Placeholder
                        style: TextStyle(fontSize: 16, color: Colors.white), // White text
                      ),
                      const SizedBox(height: 4), // Corrected height
                      const Text(
                        'Colour: Black and silver', // Placeholder
                        style: TextStyle(fontSize: 16, color: Colors.white), // White text
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // Increased spacing between buttons
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.go('/found-items'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.amber, // Placeholder color
                        // primary: Colors.amber, // Button color - deprecated
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text('Found items'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.go('/messages'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.amber, // Placeholder color
                        // primary: Colors.amber, // Button color - deprecated
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text('Messages'),
            ),
          ],
        ),
      ),
    );
  }
}