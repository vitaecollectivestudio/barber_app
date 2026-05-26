import 'package:flutter/material.dart';

class OperatorSelector extends StatelessWidget {

  final bool isMobile;
  final bool isTablet;

  final List<Map<String, String>> operators;

  final String selectedOperator;

  final Function(String) onSelected;

  const OperatorSelector({
    super.key,
    required this.isMobile,
    required this.isTablet,
    required this.operators,
    required this.selectedOperator,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {

final allOperators = [
  {
    "nome": "Tutti",
    "img": "",
  },
  ...operators,
];

    return SizedBox(
     height: isMobile ? 152 : 170,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,

        padding:
            const EdgeInsets.symmetric(horizontal: 16),

        itemCount: allOperators.length,

        itemBuilder: (context, index) {

         final op = allOperators[index];

          final selezionato =
              selectedOperator == op["nome"]!;

          return GestureDetector(
            onTap: () {
              onSelected(op["nome"]!);
            },

            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 250),

              margin: const EdgeInsets.only(right: 12),

              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 14 : 18,
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
                      ? [
                          const Color(0xFF1F1F1F),
                          const Color(0xFF111111),
                        ]
                      : [
                          const Color(0xFF1A1A1A),
                          const Color(0xFF101010),
                        ],
                ),

                borderRadius:
                    BorderRadius.circular(30),

                border: Border.all(
                  color: selezionato
                      ? const Color(0xFF00C853)
                          .withOpacity(0.25)
                      : Colors.white.withOpacity(0.04),
                ),

                boxShadow: [

                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.40),

                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),

                  if (selezionato)
                    BoxShadow(
                      color: const Color(0xFF00C853)
                          .withOpacity(0.10),

                      blurRadius: 20,
                    ),
                ],
              ),

              child: Column(
                mainAxisAlignment:
    MainAxisAlignment.start,

mainAxisSize: MainAxisSize.min,

                children: [

                  Container(
                    padding: const EdgeInsets.all(3),

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      border: Border.all(
                        color: selezionato
                            ? const Color(0xFF00C853)
                            : Colors.white
                                .withOpacity(0.08),
                      ),

                      boxShadow: [

                        if (selezionato)
                          BoxShadow(
                            color:
                                const Color(0xFF00C853)
                                    .withOpacity(0.18),

                            blurRadius: 16,
                          ),
                      ],
                    ),

                    child: CircleAvatar(
  radius:
      isMobile ? 26 : 34,

  backgroundColor:
      const Color(0xFF1E1E1E),

  backgroundImage:
      op["img"] != ""
          ? AssetImage(op["img"]!)
          : null,

  child: op["img"] == ""
      ? Icon(
          Icons.groups_rounded,
          color: selezionato
              ? const Color(0xFF00E676)
              : Colors.white54,
          size: isMobile ? 24 : 28,
        )
      : null,
),
                  ),

                  SizedBox(
                    height: isMobile ? 10 : 14,
                  ),

                  Text(
                    op["nome"]!,

                    style: TextStyle(
                      fontSize:
                          isMobile ? 12 : 14,

                      fontWeight: FontWeight.w700,

                      letterSpacing: 0.3,

                      color: selezionato
                          ? Colors.white
                          : Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}