import 'package:coach/database/database.dart';
import 'package:coach/database/local_database.dart';
import 'package:coach/database/profile.dart';
import 'package:coach/import.dart';
import 'package:coach/line_chart.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocalDatabase(),
      child: const MyApp(),
    ),
  );
  logger.d("Platform is: $defaultTargetPlatform");
  updateWindowsPrefs();
}

// TODO: 10/6/2023 Replace with a Database method
List<FlSpot> testData = [
  const FlSpot(0, 3),
  const FlSpot(2.6, 2),
  const FlSpot(4.9, 5),
  const FlSpot(6.8, 3.1),
  const FlSpot(8, 4),
  const FlSpot(9.5, 3),
  const FlSpot(11, 4),
];

final Database database = LocalDatabase();

Future updateWindowsPrefs() async {
  if (defaultTargetPlatform == TargetPlatform.windows) {
    await DesktopWindow.setWindowSize(const Size(1000, 1200));
  } else {
    logger.d("Skipping window resize because not on a Windows platform");
  }
}

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

  var data = [const FlSpot(0, 0)];

  // TODO: 10/7/2023 Test code, replace with user interactions after the code matures
  Profile get profile => database.profiles().first;

  void _incrementCounter() {
    setState(() {
      _counter++;
      data.clear();
      data.addAll(testData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: lineChart(context, _counter, const CoachLineChart()),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget lineChart(BuildContext context, int counter, CoachLineChart chart) {
  return Center(
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
