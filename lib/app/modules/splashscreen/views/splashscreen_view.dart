import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashscreenView extends StatefulWidget {
  const SplashscreenView({Key? key}) : super(key: key);

  @override
  _SplashscreenViewState createState() => _SplashscreenViewState();
}

class _SplashscreenViewState extends State<SplashscreenView>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutBack, // This provides a slight bounce effect
      ),
    );

    _animationController!.forward().whenComplete(() => _navigateToSignup());
  }

  void _navigateToSignup() async {
    await Future.delayed(
        Duration(seconds: 2)); // Keep the splash screen a little longer
    if (mounted) {
      Get.offNamed('/signup'); // Navigate to signup screen
    }
  }

  @override
  void dispose() {
    _animationController
        ?.dispose(); // Dispose the controller to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue.shade900, Colors.blue.shade200],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _opacityAnimation!,
            child: ScaleTransition(
              scale: _scaleAnimation!,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logotransparent.png',width: 300,height: 300,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
