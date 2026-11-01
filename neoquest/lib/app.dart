import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'data/activity_api.dart';
import 'models/quest_filters.dart';
import 'screens/activity_detail_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/filters_screen.dart';
import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';
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
  late final Future<User?> _session = FirebaseAuth.instance
      .authStateChanges()
      .first;
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final String _requestedPath = _browserPath;
  bool _initialRouteHandled = false;

  String get _browserPath {
    final uri = Uri.base;
    return uri.hasScheme
        ? '${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}'
        : '/';
  }

  Widget _page(String path, {Object? arguments}) {
    final uri = Uri.tryParse(path) ?? Uri(path: '/');
    final normalized = uri.path.isEmpty ? '/' : uri.path;
    final query = uri.queryParameters;
    final protected =
        normalized == '/home' ||
        normalized == '/filters' ||
        normalized == '/list' ||
        normalized == '/explore' ||
        normalized == '/map' ||
        normalized.startsWith('/activity/');

    if (protected && FirebaseAuth.instance.currentUser == null) {
      final target = '$normalized${uri.hasQuery ? '?${uri.query}' : ''}';
      return AppShell(child: AuthScreen(isSignUp: false, returnTo: target));
    }
    final filters = QuestFilters.fromQuery(query);
    if (normalized == '/') return const LandingScreen();
    if (normalized == '/signin' || normalized == '/signup') {
      final returnTo = query['returnTo'] ?? '/home';
      return AppShell(
        child: AuthScreen(
          isSignUp: normalized == '/signup',
          returnTo: returnTo,
        ),
      );
    }
    if (normalized == '/home') return AppShell(child: HomeScreen(api: api));
    if (normalized == '/filters') {
      return AppShell(child: FiltersScreen(filters: filters));
    }
    if (normalized == '/list' || normalized == '/explore') {
      return AppShell(
        child: ExploreScreen(api: api, initialFilters: filters),
      );
    }
    if (normalized == '/map') {
      return AppShell(
        child: MapScreen(api: api, filters: filters),
      );
    }
    if (normalized.startsWith('/activity/')) {
      final id = Uri.decodeComponent(normalized.substring('/activity/'.length));
      return AppShell(
        child: ActivityDetailScreen(api: api, activityId: id),
      );
    }
    return AppShell(child: HomeScreen(api: api));
  }

  Route<dynamic> _route(RouteSettings settings) {
    final path = settings.name ?? '/';
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => _page(path, arguments: settings.arguments),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NeoQuest — Find your next side quest',
    debugShowCheckedModeBanner: false,
    theme: NeoTheme.light,
    navigatorKey: _navigatorKey,
    routes: {'/': (_) => const LandingScreen()},
    initialRoute: '/',
    onGenerateRoute: _route,
    builder: (context, child) => FutureBuilder<User?>(
      future: _session,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFF101815),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFB8F36B)),
            ),
          );
        }
        if (!_initialRouteHandled) {
          _initialRouteHandled = true;
          if (_requestedPath.isNotEmpty && _requestedPath != '/') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  _requestedPath,
                  (_) => false,
                );
              }
            });
          }
        }
        return child ?? const SizedBox.shrink();
      },
    ),
  );
}
