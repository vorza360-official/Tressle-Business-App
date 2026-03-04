import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EmployeePerformanceChart extends StatelessWidget {
  const EmployeePerformanceChart({Key? key}) : super(key: key);

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Color(0xFF305CDE),
          width: 40, // set bar width
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  );
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = 'SUN';
                      break;
                    case 1:
                      text = 'TUE';
                      break;
                    case 2:
                      text = 'WED';
                      break;
                    case 3:
                      text = 'THU';
                      break;
                    case 4:
                      text = 'FRI';
                      break;
                    case 5:
                      text = 'SAT';
                      break;
                    default:
                      text = '';
                  }
                  return Text(text, style: style);
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          barGroups: [
            makeGroupData(0, 75),
            makeGroupData(1, 55),
            makeGroupData(2, 95),
            makeGroupData(3, 45),
            makeGroupData(4, 65),
            makeGroupData(5, 85),
          ],
        ),
      ),
    );
  }
}
