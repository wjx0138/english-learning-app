import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../data/models/learning_data.dart';

/// Learning Curve Chart Widget
class LearningCurveChart extends StatelessWidget {
  final List<LearningData> data;

  const LearningCurveChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '学习曲线',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '过去 7 天的学习进度',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                _buildChartData(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '暂无学习数据',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '开始学习后将显示进度',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LineChartData _buildChartData() {
    // Sort data by date
    final sortedData = List<LearningData>.from(data);
    sortedData.sort((a, b) => a.date.compareTo(b.date));

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _calculateInterval(sortedData),
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey[300],
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < sortedData.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MM/dd').format(sortedData[index].date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              );
            },
            interval: _calculateInterval(sortedData),
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[300]!),
      ),
      minX: 0,
      maxX: (sortedData.length - 1).toDouble(),
      minY: 0,
      maxY: _calculateMaxY(sortedData),
      lineBarsData: [
        LineChartBarData(
          spots: _buildSpots(sortedData),
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.3),
              Colors.blue,
            ],
          ),
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.blue,
                strokeWidth: 2,
              );
            },
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              if (index >= 0 && index < sortedData.length) {
                final data = sortedData[index];
                final dateStr = DateFormat('MM月dd日').format(data.date);
                final wordsStr = '学习: ${data.wordsLearned}个';
                final minutesStr = '时长: ${data.studyMinutes}分钟';
                final accuracyStr = '正确率: ${data.accuracy}%';
                return LineTooltipItem(
                  '$dateStr\n$wordsStr\n$minutesStr\n$accuracyStr',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
    );
  }

  double _calculateMaxY(List<LearningData> data) {
    if (data.isEmpty) return 10;
    final maxValue =
        data.map((d) => d.wordsLearned.toDouble()).reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2; // Add 20% padding
  }

  double _calculateInterval(List<LearningData> data) {
    final maxValue = _calculateMaxY(data);
    if (maxValue <= 5) return 1;
    if (maxValue <= 10) return 2;
    if (maxValue <= 20) return 5;
    return 10;
  }

  List<FlSpot> _buildSpots(List<LearningData> data) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].wordsLearned.toDouble()));
    }
    return spots;
  }
}
