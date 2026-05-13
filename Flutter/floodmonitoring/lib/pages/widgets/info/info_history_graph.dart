import 'package:fl_chart/fl_chart.dart';
import 'package:floodmonitoring/pages/widgets/info/info_card.dart';
import 'package:floodmonitoring/pages/widgets/info/info_date_label.dart';
import 'package:floodmonitoring/utils/colors.dart';
import 'package:flutter/material.dart';

Widget historyGraph(List<FlSpot> hourlyData, List<String> labels) {
  return card(
    "24-Hour Flood Levels (Hourly)",
    SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 23,
          lineTouchData: LineTouchData(
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      FlLine(
                        color: Colors.blueAccent.withOpacity(0.5),
                        strokeWidth: 2,
                      ),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeColor: Colors.blueAccent,
                              strokeWidth: 2,
                            ),
                      ),
                    );
                  }).toList();
                },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Colors.white,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              tooltipMargin: 10,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  int index = touchedSpot.x.toInt();

                  String dateTimeLabel = (index >= 0 && index < labels.length)
                      ? labels[index]
                      : "Loading...";

                  return LineTooltipItem(
                    '',
                    const TextStyle(fontSize: 0),
                    children: [
                      TextSpan(
                        text: "$dateTimeLabel\n",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: "${touchedSpot.y.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: " ft",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            checkToShowVerticalLine: (value) => value % 6 == 0,
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) => Text(
                  "${value.toStringAsFixed(1)}ft",
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (labels.isEmpty || index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }

                  if (index % 4 == 0 || index == 23) {
                    return dateLabel(labels[index]);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: hourlyData,
              isCurved: true,
              curveSmoothness: 0.1,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              gradient: const LinearGradient(
                colors: [gradientEnd, gradientStart],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    gradientEnd.withOpacity(0.0),
                    gradientStart.withOpacity(0.3),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
