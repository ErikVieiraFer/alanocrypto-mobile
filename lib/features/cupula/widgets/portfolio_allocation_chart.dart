import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../theme/app_theme.dart';
import '../models/portfolio_models.dart';

class PortfolioAllocationChart extends StatelessWidget {
  final List<PortfolioHolding> holdings;
  final double totalValue;

  const PortfolioAllocationChart({
    super.key,
    required this.holdings,
    required this.totalValue,
  });

  List<Color> get _colors => const [
        Color(0xFF00FF88),
        Color(0xFF3B82F6),
        Color(0xFFF59E0B),
        Color(0xFFEF4444),
        Color(0xFF8B5CF6),
        Color(0xFFEC4899),
        Color(0xFF14B8A6),
        Color(0xFF6366F1),
      ];

  @override
  Widget build(BuildContext context) {
    if (holdings.isEmpty || totalValue <= 0) {
      return const SizedBox.shrink();
    }

    final sortedHoldings = List<PortfolioHolding>.from(holdings)
      ..sort((a, b) => (b.currentValue ?? 0).compareTo(a.currentValue ?? 0));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alocação',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: PieChartPainter(
                    holdings: sortedHoldings,
                    totalValue: totalValue,
                    colors: _colors,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildLegend(sortedHoldings),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLegend(List<PortfolioHolding> sortedHoldings) {
    final List<Widget> legend = [];

    for (int i = 0; i < sortedHoldings.length && i < 6; i++) {
      final holding = sortedHoldings[i];
      final percentage =
          totalValue > 0 ? ((holding.currentValue ?? 0) / totalValue * 100) : 0.0;

      legend.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _colors[i % _colors.length],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  holding.coinSymbol.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Color(0xFF9ca3af),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (sortedHoldings.length > 6) {
      double othersValue = 0;
      for (int i = 6; i < sortedHoldings.length; i++) {
        othersValue += sortedHoldings[i].currentValue ?? 0;
      }
      final othersPercentage =
          totalValue > 0 ? (othersValue / totalValue * 100) : 0.0;

      legend.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF4B5563),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Outros',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Text(
                '${othersPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Color(0xFF9ca3af),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return legend;
  }
}

class PieChartPainter extends CustomPainter {
  final List<PortfolioHolding> holdings;
  final double totalValue;
  final List<Color> colors;

  PieChartPainter({
    required this.holdings,
    required this.totalValue,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (holdings.isEmpty || totalValue <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = radius * 0.6;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < holdings.length; i++) {
      final holding = holdings[i];
      final value = holding.currentValue ?? 0;
      final sweepAngle = (value / totalValue) * 2 * math.pi;

      final paint = Paint()
        ..color = i < 6 ? colors[i % colors.length] : const Color(0xFF4B5563)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    final innerPaint = Paint()
      ..color = AppTheme.cardDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
