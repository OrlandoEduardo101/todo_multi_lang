import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:todo_flutter/src/modules/auth/auth_binding.dart';
import 'package:todo_flutter/src/modules/auth/stores/auth_store.dart';

import 'app_widget.route.dart';

part 'app_widget.g.dart';

@Main('lib/app')
class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  final AuthStore _authStore = authModule.get<AuthStore>();

  @override
  void initState() {
    super.initState();
    _authStore.watchAuth();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authStore.watchAuthCommand,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Todo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4527A0), brightness: Brightness.dark),
            useMaterial3: true,
          ),
          routerConfig: Routefly.routerConfig(routes: routes, initialPath: routePaths.splash),
        );
      },
    );
  }
}
