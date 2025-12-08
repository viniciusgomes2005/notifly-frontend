import 'package:flutter/material.dart';

class LightBackground extends StatelessWidget {
  const LightBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage("notifly_light_background.png"),
      fit: BoxFit.scaleDown,
    );
  }
}

class DarkBackground extends StatelessWidget {
  const DarkBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage("notifly_dark_background.png"),
      fit: BoxFit.scaleDown,
    );
  }
}
