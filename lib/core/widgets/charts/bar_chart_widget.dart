import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, int> data;
  final Map<String, Color> barColors;
  final String title;
  final bool isVertical;

  const BarChartWidget({
    super.key,
    required this.data,
    required this.barColors,
    this.title = 'Tickets',
    this.isVertical = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final chartHeight = MediaQuery.of(context).size.height * 0.3;
    final maxY = (data.values.isEmpty)
        ? 0.0
        : data.values.reduce((a, b) => a > b ? a : b).toDouble() + 5;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ${data.values.fold(0, (a, b) => a + b)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 2),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              height: chartHeight,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: isVertical),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height * 0.008),
                              child: Text(
                                data.keys.elementAt(index),
                                style: TextStyle(
                                    fontSize:
                                    MediaQuery.of(context).size.height * 0.012),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(context),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(BuildContext context) {
    return data.entries.mapIndexed((index, entry) {
      final color = barColors[entry.key] ?? Colors.grey;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: color,
            width: MediaQuery.of(context).size.height * 0.02,
            borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.height * 0.004),
          ),
        ],
      );
    }).toList();
  }
}
