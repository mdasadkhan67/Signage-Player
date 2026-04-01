import 'dart:async';
import 'package:flutter/material.dart';
import 'package:signane_media_playe/screens/signage_player_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  void _startSplash() {
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignagePlayerScreen()),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo.png",
                width: MediaQuery.of(context).size.width * 0.4,
              ),

              const SizedBox(height: 20),

              const Text(
                "Signane",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Media Playe",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
