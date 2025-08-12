import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campus Lost and Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                context.go('/lost-items');
              },
              child: Text('View Lost Items'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/found-items');
              },
              child: Text('View Found Items'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/add-item');
              },
              child: Text('Report Item'),
            ),
          ],
        ),
      ),
    );
  }
}