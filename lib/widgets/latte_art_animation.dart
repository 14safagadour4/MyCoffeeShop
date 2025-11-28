import 'package:flutter/material.dart';

class LatteArtAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const LatteArtAnimation({super.key, required this.onComplete});

  @override
  State<LatteArtAnimation> createState() => _LatteArtAnimationState();
}

class _LatteArtAnimationState extends State<LatteArtAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    // On notifie quand l'animation est terminée
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _animation,
        child: ScaleTransition(
          scale: _animation,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.brown[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '☕', // Latte art simplifié
                style: TextStyle(fontSize: 64),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
