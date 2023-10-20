import 'dart:async';
import 'dart:io';

import 'package:coach/database/health_record.dart';
import 'package:coach/database/local_database.dart';
import 'package:coach/import.dart';
import 'package:coach/views/coach_line_chart.dart';
import 'package:coach/views/profile_manager.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider.value(
      value: _database,
      child: const MyApp(
        title: 'Coach',
      ),
    ),
  );
  logger.d("Platform is: $defaultTargetPlatform");
  updateWindowsPrefs();
}

Future updateWindowsPrefs() async {
  if (defaultTargetPlatform == TargetPlatform.windows) {
    await DesktopWindow.setWindowSize(const Size(1000, 1200));
  } else {
    logger.d("Skipping window resize because not on a Windows platform");
  }
}

LocalDatabase _database = LocalDatabase();

/// Main Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.title});

  final String title;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoadingScreen(
        title: title,
      ),
      // home: const MyHomePage(title: 'Coach - Vodichian'),
    );
  }
}

/// Main Widget State
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  get shouldShow => _selectedIndex == 1;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDatabase();
  }

  void _loadDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    setState(() {
      _database.load(directory);
    });
  }

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget getSelected(int index) {
    Widget widget;
    switch (index) {
      case 0:
        widget = const ProfileManager();
        break;
      case 1:
        widget = futureLineChart();
        break;
      default:
        widget = const Text("Unknown page");
    }
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: getSelected(_selectedIndex),
        // child: _widgetOptions[_selectedIndex],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Profiles'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Weight Chart'),
              selected: _selectedIndex == 1,
              onTap: () {
                // Update the state of the app
                _onItemTapped(1);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Settings'),
              selected: _selectedIndex == 2,
              onTap: () {
                // Update the state of the app
                _onItemTapped(2);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: shouldShow
          ? FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<List<HealthRecord>> getRecords() async {
    logger.d('getRecords called');
    LocalDatabase database = context.read();
    if (database.state() == DatabaseState.running) {
      return database.records(database.currentProfile());
    } else {
      return [];
    }
  }

  /// Builds a [CoachLineChart] wrapped in a [FutureBuilder]
  Widget futureLineChart() {
    return FutureBuilder(
      builder: (context, snapshot) {
        Widget widget;
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.active:
            widget = const Text('Database is loading...');
            break;
          case ConnectionState.done:
            if (snapshot.hasError) {
              var message =
                  'Error loading database: ${snapshot.error.toString()}';
              logger.e(snapshot.stackTrace);
              logger.e(message);
              widget = Text(message);
            } else {
              if (snapshot.hasData) {
                widget = lineChart(snapshot.data ?? []);
              } else {
                logger.e("No data was returned");
                widget = const Text('No data was returned');
              }
            }
            break;
          default:
            widget =
                Text('Unknown connection state: ${snapshot.connectionState}');
            break;
        }
        return widget;
      },
      future: getRecords(),
    );
  }

  /// Builds a CoachLineChart widget
  Widget lineChart(List<HealthRecord> records) {
    Widget widget;
    if (records.isEmpty) {
      widget = const Text("There are no records to display");
    } else {
      CoachLineChart chart = CoachLineChart(records: records);
      widget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            chart,
          ],
        ),
      );
    }
    return widget;
  }
}

/// An initial loading screen to give the database time to synchronize with the
/// filesystem before being accessed.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.title});

  final String title;

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MyHomePage(title: widget.title)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
