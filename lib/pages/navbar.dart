import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:notifly_frontend/widgets/padscaffold.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';

typedef RouteBuilder = PageRouteInfo Function();
typedef PageData = ({
  List<String> allowedRoles,
  String label,
  RouteBuilder routeBuilder,
  Widget icon,
  Widget selectedIcon,
});

@RoutePage()
class NavBarPage extends StatefulWidget {
  const NavBarPage({super.key});

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  @override
  Widget build(BuildContext context) {
    final settBox = Hive.box('settings');
    bool isDark = settBox.get('darkMode', defaultValue: false) as bool;

    return PadScaffold(
      subtitle: "Your personal book notifier",
      actions: Switch(
        value: isDark,
        onChanged: (val) {
          settBox.put('darkMode', val);
          setState(() {
            isDark = val;
          });
        },
      ),
      useDarkLogo: isDark,
      body: const AutoRouter(),
    );
  }
}
