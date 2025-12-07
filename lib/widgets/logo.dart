import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 224, minWidth: 224),
      child: const Image(
        image: AssetImage("notifly_logo.png"),
        fit: BoxFit.scaleDown,
      ),
    );
  }
}

class DarkLogo extends StatelessWidget {
  const DarkLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 224, minWidth: 224),
      child: const Image(
        image: AssetImage("notifly_logo_dark.png"),
        fit: BoxFit.scaleDown,
      ),
    );
  }
}
