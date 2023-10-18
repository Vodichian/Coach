import 'package:coach/app_colors.dart';
import 'package:coach/database/health_record.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LineChartDataBuilder {
  var logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  static final List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  final List<Widget> _labelWidgets = [];

  LineChartData loadData(List<HealthRecord> records) {
    if (records.isEmpty) {
      return LineChartData();
    }
    logger.d("Loaded ${records.length} records");
    List<FlSpot> data = convert(records);
    makeLabels(records.first, data);
    // TODO: 10/14/2023 test code, replace with formal min/max extraction
    double min = data.first.x;
    double max = data.last.x;

    logger.d('min = $min, max = $max');
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: min,
      maxX: max,
      minY: 60,
      maxY: 85,
      lineBarsData: [
        LineChartBarData(
          spots: data,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    int index = value ~/ 7; // remainder intentionally lost
    Widget text;
    if (value % 7 == 0) {
      text = _labelWidgets[index];
    } else {
      text = const Text("", style: style);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 10:
        text = '10';
        break;
      case 20:
        text = '20';
        break;
      case 30:
        text = '30';
        break;
      case 40:
        text = '40';
        break;
      case 50:
        text = '50';
        break;
      case 60:
        text = '60';
        break;
      case 70:
        text = '70';
        break;
      case 80:
        text = '80';
        break;
      case 90:
        text = '90';
        break;
      case 100:
        text = '100';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  List<FlSpot> convert(List<HealthRecord> records) {
    List<FlSpot> list = [];
    if (records.isEmpty) return list;

    /// normalize the x axis as time intervals starting from the first entry
    var first = records.removeAt(0);
    list.add(FlSpot(0, first.weight));
    for (var record in records) {
      list.add(FlSpot(
          record.date.difference(first.date).inDays.toDouble(), record.weight));
    }
    logger.d("List: $list");
    return list;
  }

  /// Generate labels for x-axis from [data]
  void makeLabels(final HealthRecord first, List<FlSpot> data) {
    if (data.isEmpty) return;
    DateTime dayZero = first.date;
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    String label = '${dayZero.month}/${dayZero.day}';
    var widget = Text(label, style: style);
    _labelWidgets.clear();
    _labelWidgets.add(widget);
    for (var i = 1; i < 12; i++) {
      DateTime nextWeek = dayZero.add(Duration(days: 7 * i));
      label = '${nextWeek.month}/${nextWeek.day}';
      _labelWidgets.add(Text(label, style: style));
    }
  }
}
