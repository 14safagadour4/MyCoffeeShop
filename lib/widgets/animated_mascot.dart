import 'package:flutter/material.dart';

class AnimatedMascot extends StatefulWidget {
  const AnimatedMascot({super.key});

  @override
  State<AnimatedMascot> createState() => _AnimatedMascotState();
}

class _AnimatedMascotState extends State<AnimatedMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // 🐻 Bear Body
            const Text(
              "🐻",
              style: TextStyle(fontSize: 80),
            ),
            // 🙋‍♂️ Wave hand
            Positioned(
              top: 5,
              right: 0,
              child: AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _waveAnimation.value,
                    alignment: Alignment.bottomLeft,
                    child: const Text(
                      "👋",
                      style: TextStyle(fontSize: 36),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "Hi!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
