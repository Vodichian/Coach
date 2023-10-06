import 'dart:io' as io;

import 'package:coach/import.dart';
import 'package:coach/line_chart.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
  logger.d("Platform is: $defaultTargetPlatform");
  testWindowFunctions();
}

List<FlSpot> testData = [
  const FlSpot(0, 3),
  const FlSpot(2.6, 2),
  const FlSpot(4.9, 5),
  const FlSpot(6.8, 3.1),
  const FlSpot(8, 4),
  const FlSpot(9.5, 3),
  const FlSpot(11, 4),
];

Future testWindowFunctions() async {
  await DesktopWindow.setWindowSize(const Size(800, 800));

  // await DesktopWindow.setMinWindowSize(Size(400, 400));
  // await DesktopWindow.setMaxWindowSize(Size(800, 800));
  //
  // await DesktopWindow.resetMaxWindowSize();
  // await DesktopWindow.toggleFullScreen();
  // bool isFullScreen = await DesktopWindow.getFullScreen();
  // await DesktopWindow.setFullScreen(true);
  // await DesktopWindow.setFullScreen(false);
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

// CoachLineChart chart = CoachLineChart(data: data);

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final io.File dataFile =
      io.File('C:\\Users\\Rick\\Nextcloud\\BodyComposition_202307-202309.csv');

  var data = [const FlSpot(0,0)];

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      data.clear();
      data.addAll(testData);
      if (defaultTargetPlatform == TargetPlatform.windows) {
        testWindowFunctions();
      } else {
        logger.d("Skipping window resize because not on a Windows platform");
      }
      Importer().loadFile(dataFile);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: lineChart(context, _counter, CoachLineChart(data: data)),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
