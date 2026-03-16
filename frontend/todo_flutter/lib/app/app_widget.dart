import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';

import 'app_widget.route.dart';

part 'app_widget.g.dart';

@Main('lib/app')
class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Todo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4527A0), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      routerConfig: Routefly.routerConfig(routes: routes, initialPath: routePaths.splash),
    );
  }
}
