import 'package:flutter/material.dart';
import 'dart:async';
import 'chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ChatScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Center(
              child: Image.asset(
                'assets/logo_1.png',
                width: 300,
                height: 300,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Text(
                'Developed by Mina Philip',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
