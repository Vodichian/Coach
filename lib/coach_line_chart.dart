import 'package:coach/app_colors.dart';
import 'package:coach/database/health_record.dart';
import 'package:coach/database/local_database.dart';
import 'package:coach/line_chart_data_builder.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CoachLineChart extends StatefulWidget {
  const CoachLineChart({super.key});

  @override
  State<CoachLineChart> createState() => _CoachLineChartState();
}

class _CoachLineChartState extends State<CoachLineChart> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  bool showAvg = false;

  final LineChartDataBuilder _builder = LineChartDataBuilder();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              _builder.loadData(getData()),
              // _builder.loadData(getData()),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'avg',
              style: TextStyle(
                fontSize: 12,
                color: showAvg ? Colors.black.withOpacity(0.5) : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<HealthRecord> getData() {
    LocalDatabase database = context.read();
    return database.records(database.currentProfile());
  }
}
