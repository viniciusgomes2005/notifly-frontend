import 'package:auto_route/auto_route.dart';
import 'package:notifly_frontend/router/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      path: '/notifly',
      page: NavBarRoute.page,
      initial: true,
      children: [
        CustomRoute(
          page: HomeRoute.page,
          path: 'home',
          initial: true,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
      ],
    ),
  ];
}
