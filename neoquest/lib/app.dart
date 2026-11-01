import 'package:flutter/material.dart';

import 'data/activity_api.dart';
import 'screens/activity_detail_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'theme.dart';
import 'widgets/app_shell.dart';

class NeoQuestApp extends StatefulWidget {
  const NeoQuestApp({super.key});

  @override
  State<NeoQuestApp> createState() => _NeoQuestAppState();
}

class _NeoQuestAppState extends State<NeoQuestApp> {
  late final ActivityApi api = FirestoreActivityApi();

  Route<dynamic> _route(RouteSettings settings) {
    final path = settings.name ?? '/';
    if (path.startsWith('/activity/')) {
      final id = Uri.decodeComponent(path.substring('/activity/'.length));
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => AppShell(
          child: ActivityDetailScreen(api: api, activityId: id),
        ),
      );
    }
    if (path == '/explore') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => AppShell(child: ExploreScreen(api: api)),
      );
    }
    if (path == '/map') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => AppShell(child: MapScreen(api: api)),
      );
    }
    if (path == '/signin' || path == '/signup') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) =>
            AppShell(child: AuthScreen(isSignUp: path == '/signup')),
      );
    }
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => AppShell(child: HomeScreen(api: api)),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NeoQuest — Find your next side quest',
    debugShowCheckedModeBanner: false,
    theme: NeoTheme.light,
    initialRoute: '/',
    onGenerateRoute: _route,
  );
}
