import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';

class BookingTimeGrid extends StatelessWidget {

  final List<String> orari;
  final String? selected;
  final Function(String) onSelect;

  const BookingTimeGrid({
    super.key,
    required this.orari,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {

    final isTablet =
        Responsive.isTablet(context);

    final isDesktop =
        Responsive.isDesktop(context);

    return GridView.builder(

      shrinkWrap: true,

      physics:
          const NeverScrollableScrollPhysics(),

      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(

        crossAxisCount:
            isDesktop
                ? 5
                : isTablet
                    ? 4
                    : 3,

        mainAxisSpacing:
            isDesktop
                ? 20
                : 14,

        crossAxisSpacing:
            isDesktop
                ? 20
                : 14,

        childAspectRatio:
            isDesktop
                ? 2.8
                : isTablet
                    ? 2.5
                    : 2.2,
      ),

      itemCount: orari.length,

      itemBuilder: (context, index) {

        final ora = orari[index];

        final selezionato =
            selected == ora;

        return GestureDetector(

          onTap: () => onSelect(ora),

          child: AnimatedScale(

            scale:
                selezionato
                    ? 1.04
                    : 1,

            duration:
                const Duration(
                  milliseconds: 180,
                ),

            curve: Curves.easeOutCubic,

            child: AnimatedContainer(

              duration:
                  const Duration(
                    milliseconds: 180,
                  ),

              decoration: BoxDecoration(

                gradient: selezionato

    ? LinearGradient(

        begin: Alignment.topLeft,
        end: Alignment.bottomRight,

        colors: [

          Colors.white,

          Colors.white.withOpacity(0.92),
        ],
      )

    : const LinearGradient(

        begin: Alignment.topLeft,
        end: Alignment.bottomRight,

        colors: [

          Color(0xFF232323),

          Color(0xFF161616),
        ],
      ),

                borderRadius: BorderRadius.circular(22),

                border: Border.all(

  color: selezionato
      ? Colors.white
      : Colors.white.withOpacity(0.06),

  width: 1.4,
),

                boxShadow: [

  // 🔥 base shadow
  BoxShadow(

    color: Colors.black.withOpacity(0.35),

    blurRadius: 14,

    offset: const Offset(0, 8),
  ),

  // 🔥 selected glow
  if (selezionato)

    BoxShadow(

      color: Colors.white.withOpacity(0.18),

      blurRadius: 20,

      spreadRadius: 1,
    ),
],
              ),

              alignment: Alignment.center,

              child: FittedBox(

                fit: BoxFit.scaleDown,

                child: Padding(

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),

                  child: Text(

                    ora,

                    style: TextStyle(

                      color: selezionato
    ? Colors.black
    : Colors.white,

                      fontWeight: FontWeight.w800,

                      fontSize:
                          isDesktop
                              ? 16
                              : isTablet
                                  ? 15
                                  : 14,

                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}