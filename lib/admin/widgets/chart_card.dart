// lib/widgets/chart_card.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Make sure you have fl_chart in your pubspec.yaml

class ChartCard extends StatelessWidget {
  final Widget chart; // Expects a FlChart widget like LineChart, BarChart, etc.

  const ChartCard({
    Key? key,
    required this.chart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Data', // You might want to make this dynamic
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, // Define a height for the chart
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}