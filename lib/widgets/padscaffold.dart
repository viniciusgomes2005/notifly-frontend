import 'package:flutter/material.dart';
//import 'package:hive_flutter/adapters.dart';
import 'package:notifly_frontend/colors.dart';
import 'package:notifly_frontend/extensions.dart';

class PadScaffold extends StatelessWidget {
  const PadScaffold({
    super.key,
    required this.body,
    this.title = "",
    this.subtitle = "",
    this.actions,
  });
  final Widget body;
  final String title;
  final String subtitle;
  final Widget? actions;
  @override
  Widget build(BuildContext context) {
    //final username = Hive.box("userData").get("username") ?? "";
    //final isAdm = Hive.box("userData").get("role") == "admin" ? true : false;
    return Scaffold(
      backgroundColor: beige,
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
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(color: grey, fontSize: 12),
                        ),
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
