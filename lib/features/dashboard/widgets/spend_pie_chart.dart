import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/categories.dart';

class CategoryTotal {
  final CategoryInfo category;
  final double total;

  const CategoryTotal(this.category, this.total);
}

class SpendPieChart extends StatelessWidget {
  final List<CategoryTotal> totals;
  final double grandTotal;

  const SpendPieChart({
    super.key,
    required this.totals,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    final sections = totals.map((t) {
      final pct = grandTotal == 0 ? 0.0 : (t.total / grandTotal) * 100;
      return PieChartSectionData(
        value: t.total,
        color: t.category.color,
        title: pct >= 8 ? '${pct.toStringAsFixed(0)}%' : '',
        radius: 54,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }).toList();

    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 3,
          centerSpaceRadius: 46,
          startDegreeOffset: -90,
        ),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }
}
