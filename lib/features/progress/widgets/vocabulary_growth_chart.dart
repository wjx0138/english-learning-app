import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../data/models/learning_data.dart';

/// Vocabulary Growth Chart Widget
class VocabularyGrowthChart extends StatelessWidget {
  final List<VocabularyGrowthData> data;

  const VocabularyGrowthChart({
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '词汇量增长',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildTotalWordsBadge(context),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '总词汇量变化趋势',
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
                Icons.trending_up,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '暂无词汇增长数据',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '开始学习后将显示增长趋势',
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

  Widget _buildTotalWordsBadge(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox();
    }

    final totalWords = data.last.totalWords;
    final firstWords = data.first.totalWords;
    final growth = totalWords - firstWords;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '当前词汇量',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$totalWords',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '词',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          if (growth > 0)
            Text(
              '+$growth',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  LineChartData _buildChartData() {
    // Sort data by date
    final sortedData = List<VocabularyGrowthData>.from(data);
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
              Colors.green.withOpacity(0.3),
              Colors.green,
            ],
          ),
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.green,
                strokeWidth: 2,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.green.withOpacity(0.1),
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
                final totalStr = '总词汇量: ${data.totalWords}个';
                final newStr = data.newWords > 0 ? '新增: +${data.newWords}个' : '';
                return LineTooltipItem(
                  '$dateStr\n$totalStr${newStr.isNotEmpty ? '\n$newStr' : ''}',
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

  double _calculateMaxY(List<VocabularyGrowthData> data) {
    if (data.isEmpty) return 50;
    final maxValue =
        data.map((d) => d.totalWords.toDouble()).reduce((a, b) => a > b ? a : b);
    return maxValue * 1.1; // Add 10% padding
  }

  double _calculateInterval(List<VocabularyGrowthData> data) {
    final maxValue = _calculateMaxY(data);
    if (maxValue <= 20) return 5;
    if (maxValue <= 50) return 10;
    if (maxValue <= 100) return 20;
    return 50;
  }

  List<FlSpot> _buildSpots(List<VocabularyGrowthData> data) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].totalWords.toDouble()));
    }
    return spots;
  }
}
