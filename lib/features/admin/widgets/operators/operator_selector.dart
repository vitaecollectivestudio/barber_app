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
  final screenWidth = MediaQuery.of(context).size.width;
  final smallPhone = isMobile && screenWidth < 380;

  final allOperators = [
    {"id": "Tutti", "nome": "Tutti", "img": ""},
    ...operators,
  ];

  final selectorHeight = isMobile
      ? smallPhone
          ? 118.0
          : 132.0
      : 170.0;

  final cardWidth = isMobile
      ? smallPhone
          ? 104.0
          : 118.0
      : isTablet
          ? 170.0
          : 150.0;

  final horizontalPadding = smallPhone ? 12.0 : 16.0;
  final cardRadius = isMobile ? 26.0 : 30.0;

  return SizedBox(
    height: selectorHeight,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      itemCount: allOperators.length + 1,
      itemBuilder: (context, index) {
        if (index == allOperators.length) {
          return GestureDetector(
            onTap: onAddOperator,
            child: Container(
              width: cardWidth,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1F1F1F),
                    Color(0xFF101010),
                  ],
                ),
                borderRadius: BorderRadius.circular(cardRadius),
                border: Border.all(
                  color: const Color(0xFF00C853).withOpacity(0.25),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  size: smallPhone ? 28 : isMobile ? 31 : 42,
                  color: const Color(0xFF00C853),
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
              horizontal: smallPhone ? 10 : isMobile ? 12 : 16,
              vertical: smallPhone ? 8 : isMobile ? 10 : 18,
            ),
            width: cardWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: selezionato
                    ? [
                        const Color(0xFF1F1F1F),
                        const Color(0xFF111111),
                      ]
                    : [
                        const Color(0xFF1A1A1A),
                        const Color(0xFF101010),
                      ],
              ),
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(
                color: selezionato
                    ? const Color(0xFF00C853).withOpacity(0.25)
                    : Colors.white.withOpacity(0.04),
              ),
              boxShadow: selezionato
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00C853).withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 105;

                final avatarRadius = compact
                    ? 17.0
                    : isMobile
                        ? 21.0
                        : 34.0;

                final avatarPadding = compact
                    ? 1.5
                    : isMobile
                        ? 2.0
                        : 3.0;

                final avatarFontSize = compact
                    ? 17.0
                    : isMobile
                        ? 20.0
                        : 24.0;

                final gap = compact
                    ? 6.0
                    : isMobile
                        ? 9.0
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
                        backgroundImage: img.isNotEmpty && img.startsWith("http")
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
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: nameFontSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.25,
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
