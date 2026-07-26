import 'package:flutter/material.dart';

class CalendarLegend extends StatelessWidget {
  final bool isMobile;

  const CalendarLegend({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 390;

          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 12,
              vertical: compact ? 9 : 11,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(compact ? 18 : 22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A1A),
                  Color(0xFF101010),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Wrap(
              spacing: compact ? 8 : 12,
              runSpacing: compact ? 8 : 9,
              alignment: WrapAlignment.center,
              children: const [
                _LegendItem(
                  color: Color(0xFF89978A),
                  label: "Libero",
                ),
                _LegendItem(
                  color: Color(0xFF2A2A2A),
                  label: "Parziale",
                ),
                _LegendItem(
                  color: Colors.redAccent,
                  label: "Pieno",
                ),
                _LegendItem(
                  color: Color(0xFF050505),
                  label: "Chiuso",
                ),
                _LegendItem(
                  color: Color(0xFF00C853),
                  label: "Selezionato",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = MediaQuery.of(context).size.width < 390;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 6 : 7,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.045),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 7 : 8,
                height: compact ? 7 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 0.7,
                  ),
                ),
              ),
              SizedBox(width: compact ? 5 : 6),
              Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.62),
                  fontSize: compact ? 8.5 : 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}