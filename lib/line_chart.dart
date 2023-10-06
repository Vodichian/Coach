import 'package:coach/app_colors.dart';
import 'package:coach/line_chart_data_builder.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CoachLineChart extends StatefulWidget {
  final List<FlSpot> data;

  const CoachLineChart({super.key, required this.data});

  @override
  State<CoachLineChart> createState() => _CoachLineChartState();

}

class _CoachLineChartState extends State<CoachLineChart> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  bool showAvg = false;


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
              LineChartDataBuilder(widget.data).loadData(widget.data),
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
}