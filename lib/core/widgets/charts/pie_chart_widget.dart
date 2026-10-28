import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, int> ticketCounts;
  final Map<String, Color> ticketColors;
  final String title;

  const PieChartWidget({
    super.key,
    required this.ticketCounts,
    required this.ticketColors,
    this.title = 'Tickets',
  });

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final totalTickets = widget.ticketCounts.values.fold(0, (a, b) => a + b);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final chartHeight = screenHeight * 0.2;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Tickets: $totalTickets',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.05,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Divider(thickness: 2),
          SizedBox(height: screenHeight * 0.01),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.ticketCounts.entries.map((entry) {
                    final color = widget.ticketColors[entry.key] ?? Colors.grey;
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.004),
                      child: Row(
                        children: [
                          Container(
                            width: screenWidth * 0.04,
                            height: screenWidth * 0.04,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Flexible(
                            child: Text(
                              '${entry.key}: ${entry.value}',
                              style: TextStyle(fontSize: screenWidth * 0.030),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),


              Flexible(
                flex: 4,
                child: SizedBox(
                  height: chartHeight,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: chartHeight * 0.10,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, pieTouchResponse) {
                          setState(() {
                            if (pieTouchResponse != null &&
                                pieTouchResponse.touchedSection != null) {
                              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            } else {
                              touchedIndex = null;
                            }
                          });
                        },
                      ),
                      sections: widget.ticketCounts.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final label = entry.value.key;
                        final value = entry.value.value.toDouble();
                        final color = widget.ticketColors[label] ?? Colors.grey;
                        final isTouched = index == touchedIndex;
                        return PieChartSectionData(
                          value: value,
                          color: color,
                          title: '',
                          radius: isTouched ? chartHeight * 0.35 : chartHeight * 0.3,
                          titleStyle: TextStyle(
                            fontSize: chartHeight * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
