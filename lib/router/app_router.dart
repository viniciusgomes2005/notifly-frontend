import 'package:auto_route/auto_route.dart';
import 'package:notifly_frontend/router/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: '/home', page: HomeRoute.page, initial: true),
  ];
}
