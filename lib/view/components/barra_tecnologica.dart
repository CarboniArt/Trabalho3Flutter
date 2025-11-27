// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class BarraTecnologica extends StatelessWidget {
  final Color color;

  const BarraTecnologica({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.3, end: 1),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          height: 3,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(value * 0.2),
                color.withOpacity(value),
                color.withOpacity(value * 0.2),
              ],
            ),
          ),
        );
      },
    );
  }
}
