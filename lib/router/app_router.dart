import 'package:auto_route/auto_route.dart';
import 'package:notifly_frontend/guards/auth_guard.dart';
import 'package:notifly_frontend/router/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: '/login', page: LoginRoute.page),
    AutoRoute(path: '/register', page: RegisterRoute.page),
    AutoRoute(
      path: '/notifly',
      page: NavBarRoute.page,
      initial: true,
      guards: [AuthGuard()],
      children: [
        CustomRoute(
          page: HomeRoute.page,
          path: 'home',
          initial: true,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        CustomRoute(
          page: ChatRoute.page,
          path: 'chat/:chatId',
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
      ],
    ),
  ];
}
