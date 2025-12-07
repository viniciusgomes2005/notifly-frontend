import 'package:flutter/material.dart';
//import 'package:hive_flutter/adapters.dart';
import 'package:notifly_frontend/extensions.dart';
import 'package:notifly_frontend/widgets/logo.dart';

class PadScaffold extends StatelessWidget {
  const PadScaffold({
    super.key,
    required this.body,
    this.title = "",
    this.subtitle = "",
    this.actions,
    this.useDarkLogo = false,
  });
  final Widget body;
  final String title;
  final String subtitle;
  final Widget? actions;
  final bool useDarkLogo;
  @override
  Widget build(BuildContext context) {
    //final username = Hive.box("userData").get("username") ?? "";
    //final isAdm = Hive.box("userData").get("role") == "admin" ? true : false;
    final Widget logoWidg = useDarkLogo ? const DarkLogo() : const Logo();
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 1000),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: KeyedSubtree(
                            key: ValueKey<bool>(useDarkLogo),
                            child: logoWidg,
                          ),
                        ),
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        Text(subtitle, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    if (actions != null) actions!,
                    if (actions == null) const SizedBox(width: 16),
                  ],
                ).withPadding(
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                ),
                Expanded(child: SingleChildScrollView(child: body)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
