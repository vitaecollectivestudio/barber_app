import 'package:flutter/material.dart';

class OperatorSelector extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final List<Map<String, String>> operators;
  final String selectedOperator;
  final Function(String) onSelected;
  final VoidCallback onAddOperator;

  const OperatorSelector({
    super.key,
    required this.isMobile,
    required this.isTablet,
    required this.operators,
    required this.selectedOperator,
    required this.onSelected,
    required this.onAddOperator,
  });

  @override
  Widget build(BuildContext context) {
    final allOperators = [
      {"id": "Tutti", "nome": "Tutti", "img": ""},
      ...operators,
    ];

    return SizedBox(
      height: isMobile ? 125 : 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allOperators.length + 1,
        itemBuilder: (context, index) {
          if (index == allOperators.length) {
            return GestureDetector(
              onTap: onAddOperator,
              child: Container(
                width: isMobile
                    ? 118
                    : isTablet
                    ? 170
                    : 150,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1F1F1F), Color(0xFF101010)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF00C853).withOpacity(0.25),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    size: isMobile ? 30 : 42,
                    color: Color(0xFF00C853),
                  ),
                ),
              ),
            );
          }

          final op = allOperators[index];

          final operatorId = op["id"] ?? op["nome"]!;
          final nome = op["nome"] ?? operatorId;
          final img = op["img"] ?? "";

          final selezionato = selectedOperator == operatorId;

          return GestureDetector(
            onTap: () {
              onSelected(operatorId);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 10 : 18,
              ),
              width: isMobile
                  ? 118
                  : isTablet
                  ? 170
                  : 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: selezionato
                      ? [const Color(0xFF1F1F1F), const Color(0xFF111111)]
                      : [const Color(0xFF1A1A1A), const Color(0xFF101010)],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: selezionato
                      ? const Color(0xFF00C853).withOpacity(0.25)
                      : Colors.white.withOpacity(0.04),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 96;
                  final avatarRadius = compact
                      ? 17.0
                      : isMobile
                      ? 20.0
                      : 34.0;
                  final avatarPadding = compact
                      ? 1.5
                      : isMobile
                      ? 2.0
                      : 3.0;
                  final avatarFontSize = compact
                      ? 18.0
                      : isMobile
                      ? 20.0
                      : 24.0;
                  final gap = compact
                      ? 6.0
                      : isMobile
                      ? 10.0
                      : 14.0;
                  final nameFontSize = compact
                      ? 11.0
                      : isMobile
                      ? 12.0
                      : 14.0;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        padding: EdgeInsets.all(avatarPadding),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selezionato
                                ? const Color(0xFF00C853)
                                : Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: const Color(0xFF1E1E1E),
                          backgroundImage:
                              img.isNotEmpty && img.startsWith("http")
                              ? NetworkImage(img)
                              : img.isNotEmpty
                              ? AssetImage(img) as ImageProvider
                              : null,
                          child: img.isEmpty
                              ? Text(
                                  nome.isNotEmpty ? nome[0].toUpperCase() : "?",
                                  style: TextStyle(
                                    color: selezionato
                                        ? const Color(0xFF00E676)
                                        : Colors.white54,
                                    fontWeight: FontWeight.w900,
                                    fontSize: avatarFontSize,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: gap),
                      Flexible(
                        child: Text(
                          nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: nameFontSize,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: selezionato ? Colors.white : Colors.white60,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
