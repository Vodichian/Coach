import 'package:coach/views/loading_screen.dart';
import 'package:coach/views/profile_manager.dart';
import 'package:coach/views/weight_chart.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'database/local_database.dart';

final Logger _logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocalDatabase(),
      child: Coach(
        title: 'Coach',
      ),
    ),
  );
  _logger.d("Platform is: $defaultTargetPlatform");
  _updateWindowsPrefs();
}

Future _updateWindowsPrefs() async {
  if (defaultTargetPlatform == TargetPlatform.windows) {
    await DesktopWindow.setWindowSize(const Size(1000, 1200));
  } else {
    _logger.d("Skipping window resize because not on a Windows platform");
  }
}

class Coach extends StatelessWidget {
  final String title;

  Coach({super.key, required this.title});

  final GoRouter _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/loading',
      routes: [
        ShellRoute(
            navigatorKey: _shellNavigatorKey,
            builder: (context, state, child) {
              return ScaffoldWithNavBar(child: child);
            },
            routes: [
              GoRoute(
                  path: '/loading',
                  builder: (context, state) {
                    return const LoadingScreen(
                      title: '',
                    );
                  }),
              GoRoute(
                  path: '/weightchart',
                  builder: (context, state) {
                    return const WeightChart();
                  }),
              GoRoute(
                  path: '/profiles',
                  builder: (context, state) {
                    return const ProfileManager();
                  }),
              GoRoute(
                  path: '/settings',
                  builder: (context, state) {
                    return const Center(
                        child: Text('Settings route placeholder'));
                  }),
            ]),
      ]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Coach',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    );
  }
}

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [child] is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  /// The widget to display in the body of the Scaffold.
  /// In this sample, it is a Navigator.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.stacked_line_chart),
            label: 'Weight Chart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Profiles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/weight')) {
      return 0;
    }
    if (location.startsWith('/profiles')) {
      return 1;
    }
    if (location.startsWith('/settings')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/weightchart');
        break;
      case 1:
        GoRouter.of(context).go('/profiles');
        break;
      case 2:
        GoRouter.of(context).go('/settings');
        break;
    }
  }
}
