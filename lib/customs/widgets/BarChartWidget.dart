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
          // Title
          Text(
            '$title: ${data.values.fold(0, (a, b) => a + b)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 2),
          const SizedBox(height: 8),

          // Bar Chart
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
          // const SizedBox(height: 16),

          // Legend below chart
          // Container(
          //   width: double.infinity,
          //   padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.016),
          //   decoration: BoxDecoration(
          //     color: Colors.grey[50],
          //     borderRadius: BorderRadius.circular(8),
          //     border: Border.all(color: Colors.grey[300]!),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: data.entries.map((entry) {
          //       final color = barColors[entry.key] ?? Colors.grey;
          //       return Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 6),
          //         child: Row(
          //           children: [
          //             Container(
          //               width: screenWidth * 0.04,
          //               height: screenWidth * 0.04,
          //               decoration: BoxDecoration(
          //                 color: color,
          //                 borderRadius: BorderRadius.circular(4),
          //               ),
          //             ),
          //             SizedBox(width: screenWidth * 0.02),
          //             Flexible(
          //               child: Text(
          //                 '${entry.key}: ${entry.value} tickets',
          //                 style: TextStyle(fontSize: screenWidth * 0.04),
          //                 overflow: TextOverflow.ellipsis,
          //               ),
          //             ),
          //           ],
          //         ),
          //       );
          //     }).toList(),
          //   ),
          // ),
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
