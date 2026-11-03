import 'package:adhil/flash_app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FlashPayApp());
}

class FlashPayApp extends StatelessWidget {
  const FlashPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flash Pay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      ),
      home: FlashHomePage(),
    );
  }
}
