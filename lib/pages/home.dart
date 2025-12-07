import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:notifly_frontend/widgets/padscaffold.dart';
import 'package:hive_flutter/adapters.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDarkMode = Hive.box("settings").get("darkMode") ?? false;
  @override
  Widget build(BuildContext context) {
    return PadScaffold(
      title: "NotiFly",
      subtitle: "Your personal book notifier",
      actions: Switch(
        value: isDarkMode,
        onChanged: (value) {
          setState(() {
            isDarkMode = value;
            Hive.box("settings").put("darkMode", isDarkMode);
          });
        },
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: Text("Go to Book Details"),
        ),
      ),
    );
  }
}
