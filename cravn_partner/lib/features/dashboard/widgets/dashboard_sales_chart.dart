import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/colors.dart';

class DashboardSalesChart extends StatelessWidget {
  const DashboardSalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revenue Trend',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Dimensions.s12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(Dimensions.s16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusMd),
            boxShadow: Dimensions.boxShadowSmall(Colors.black),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            days[value.toInt()],
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    interval: 1,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 6,
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 3),
                    FlSpot(1, 1),
                    FlSpot(2, 4),
                    FlSpot(3, 2),
                    FlSpot(4, 5),
                    FlSpot(5, 3),
                    FlSpot(6, 4),
                  ],
                  isCurved: true,
                  color: cravnPrimary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: cravnPrimary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
