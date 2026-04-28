import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool circular;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 80,
    this.circular = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = Image.asset(
      'assets/logo/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
    );

    if (circular) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color == null ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: [
            if (color == null)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipOval(child: logo),
      );
    }

    return logo;
  }
}
