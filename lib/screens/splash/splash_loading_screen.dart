import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashLoadingScreen extends StatelessWidget {
  const SplashLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade400,
      body: Stack(
        children: [
          // Background Creative Art
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          // Foreground Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 110,
                    height: 110,
                  ),
                ),
                const SizedBox(height: 35),
                // App Name
                const Text(
                  'SalePro',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your B2B Distribution Partner',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 70),
                // Custom Dots Loading
                const ThreeDotsLoading(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThreeDotsLoading extends StatefulWidget {
  const ThreeDotsLoading({super.key});

  @override
  State<ThreeDotsLoading> createState() => _ThreeDotsLoadingState();
}

class _ThreeDotsLoadingState extends State<ThreeDotsLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Delay each dot's animation based on its index
            double animationValue = (_controller.value * 2 * math.pi) - (index * math.pi / 3);
            // Calculate vertical offset using sine wave
            double dy = math.sin(animationValue) * 12;
            
            // Only apply upward offset (bounce effect)
            if (dy > 0) dy = 0;

            return Transform.translate(
              offset: Offset(0, dy),
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
