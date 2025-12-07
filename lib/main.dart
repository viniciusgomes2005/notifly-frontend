import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:notifly_frontend/router/app_router.dart';
import 'package:notifly_frontend/widgets/theme.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appRouter = AppRouter();
  setPathUrlStrategy();
  await Hive.initFlutter();
  await Hive.openBox('settings');

  runApp(MyApp(appRouter: appRouter));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');
    return ValueListenableBuilder(
      valueListenable: settingsBox.listenable(keys: ['darkMode']),
      builder: (context, box, _) {
        final bool isDark = box.get('darkMode', defaultValue: false) as bool;

        return MaterialApp.router(
          routerConfig: appRouter.config(),
          theme: nflyLightTheme,
          darkTheme: nflyDarkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}
