import 'dart:io';

import 'package:coach/database/health_record.dart';
import 'package:coach/database/local_database.dart';
import 'package:coach/import.dart';
import 'package:coach/coach_line_chart.dart';
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
      child: const MyApp(),
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Coach - Vodichian'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

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

  void _loadDatabase()  async {
    Directory directory = await getApplicationDocumentsDirectory();
    setState(() {
      _database.load(directory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder(
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
                  widget = lineChart(context, _counter, snapshot.data ?? []);
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
      ),
      // body: lineChart(context, _counter, const CoachLineChart()),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
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
}

Widget lineChart(
    BuildContext context, int counter, List<HealthRecord> records) {
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
            '$counter',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          chart,
        ],
      ),
    );
  }
  return widget;
}
