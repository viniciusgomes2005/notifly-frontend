import 'package:auto_route/auto_route.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notifly_frontend/router/app_router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (Hive.box("userData").get("id") == null) {
      resolver.redirectUntil(const LoginRoute());
      return;
    }
    resolver.next(true);
  }
}

class AdminGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (Hive.box("userData").get("role") != "admin") {
      resolver.redirectUntil(const LoginRoute());
      return;
    }
    resolver.next(true);
  }
}
