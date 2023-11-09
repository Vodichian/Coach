import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import '../database/health_record.dart';
import '../database/local_database.dart';
import 'coach_line_chart.dart';

final Logger _logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

/// Weight Chart
class WeightChart extends StatefulWidget {
  const WeightChart({super.key});

  @override
  State<StatefulWidget> createState() => WeightChartState();
}

/// Weight Chart state
class WeightChartState extends State<WeightChart> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getRecords(),
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
              _logger.e(snapshot.stackTrace);
              _logger.e(message);
              widget = Text(message);
            } else {
              if (snapshot.hasData) {
                widget = lineChart(snapshot.data ?? []);
              } else {
                _logger.e("No data was returned");
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
    );
  }

  /// Returns a Future containing the list of records
  Future<List<HealthRecord>> getRecords() async {
    _logger.d('getRecords called');
    Database database = context.read();
    if (database.state() == DatabaseState.running) {
      return database.records(database.currentProfile());
    } else {
      return [];
    }
  }

  /// Builds a CoachLineChart widget
  Widget lineChart(List<HealthRecord> records) {
    Widget widget;
    if (records.isEmpty) {
      widget = const Center(child: Text("There are no records to display"));
    } else {
      CoachLineChart chart = CoachLineChart(records: records);
      widget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Weight Chart',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            chart,
          ],
        ),
      );
    }
    return widget;
  }
}
