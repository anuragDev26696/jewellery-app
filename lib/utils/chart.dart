import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:swarn_abhushan/models/bill.dart';

class Chart extends StatelessWidget {
  final List<BillingChartModel> chartData;

  const Chart({super.key, required this.chartData});

  List<FlSpot> buildChartSpots() {
    return chartData.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.totalItems.toDouble(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: true),
        gridData: FlGridData(show: false),
        maxY: getMaxY(),
        borderData: FlBorderData(
          show: false,
          // border: Border(
          //   bottom: BorderSide(color: Color.fromARGB(255, 60, 60, 60), width: 1),
          //   left: BorderSide(color: Color.fromARGB(255, 60, 60, 60), width: 1),
          // ),
        ),

        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 10), // Off-white
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= chartData.length) {
                  return const SizedBox.shrink();
                }

                final item = chartData[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${_monthName(item.month)}\n${item.year}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),

        barGroups: buildBarGroups(context),
      ),
    );
  }
  List<BarChartGroupData> buildBarGroups(BuildContext context) {
    final gold = Theme.of(context).colorScheme.primary;
    return chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.totalItems.toDouble(),
            color: gold,
            width: 20,
            borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 0,
              color: Color.fromARGB(255,45,45,45),  
            ),
          ),
        ],
      );
    }).toList();
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
  double getMaxY() {
    if (chartData.isEmpty) return 1;
    final max = chartData.map((e) => e.totalItems).reduce((a, b) => a > b ? a : b).toDouble();
    if (chartData.length == 1) {
      return max == 0 ? 1 : max;
    }
    return max * 1.1;
  }
}
