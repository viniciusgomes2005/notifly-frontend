import 'package:flutter/material.dart';
import 'package:notifly_frontend/router/app_router.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  final appRouter = AppRouter(); // instancia
  setPathUrlStrategy();

  runApp(MyApp(appRouter: appRouter));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: appRouter.config());
  }
}
