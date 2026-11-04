import 'package:flutter/material.dart';

class helloworld extends StatelessWidget {
  const helloworld({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello, World!'),
      ),
      body: const Center(
        child: Text('Welcome to Flutter!'),
      ),
    );
  }
}