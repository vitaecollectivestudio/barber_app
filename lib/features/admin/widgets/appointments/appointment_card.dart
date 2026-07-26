import 'dart:ui';

import 'package:flutter/material.dart';

class AppointmentCard extends StatefulWidget {

  final bool isMobile;

  final Map<String, dynamic> data;

  final int index;

  final VoidCallback onDelete;

  final VoidCallback onTap;

  final Widget infoChips;

  const AppointmentCard({
    super.key,
    required this.isMobile,
    required this.data,
    required this.index,
    required this.onDelete,
    required this.onTap,
    required this.infoChips,
  });

  @override
  State<AppointmentCard> createState() =>
      _AppointmentCardState();
}

class _AppointmentCardState
    extends State<AppointmentCard> {

  bool pressed = false;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTapDown: (_) {
        setState(() {
          pressed = true;
        });
      },

      onTapUp: (_) {
        setState(() {
          pressed = false;
        });
      },

      onTapCancel: () {
        setState(() {
          pressed = false;
        });
      },

      onTap: widget.onTap,

      child: AnimatedScale(
        scale: pressed ? 0.985 : 1,

        duration:
            const Duration(milliseconds: 140),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            widget.isMobile ? 34 : 42,
          ),

          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),

            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 250),

              margin: EdgeInsets.only(
  left: widget.isMobile ? 10 : 16,
  right: widget.isMobile ? 10 : 16,
  bottom: widget.isMobile ? 9 : 22,
),

padding: EdgeInsets.all(
  widget.isMobile ? 11 : 18,
),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
  widget.isMobile ? 28 : 42,
),

                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: [
                    Color(0xFF1B1B1B),
                    Color(0xFF101010),
                  ],
                ),

                border: Border.all(
                  color:
                      Colors.white.withOpacity(0.05),
                ),

                boxShadow: [

                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.40),

                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),

                  BoxShadow(
                    color:
                        Colors.white.withOpacity(0.015),

                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
              ),

              child: LayoutBuilder(
  builder: (context, constraints) {
    final compact = widget.isMobile || constraints.maxWidth < 430;
final leadingSize = compact ? 38.0 : 54.0;
final deleteSize = compact ? 40.0 : 50.0;
final gap = compact ? 9.0 : 18.0;
final nameFontSize = compact ? 14.0 : 19.0;
final serviceFontSize = compact ? 12.5 : 15.0;
    final telefono = (widget.data['telefono'] ?? "").toString();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: leadingSize,
          height: leadingSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF222222),
                Color(0xFF111111),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
            ),
          ),
          child: Center(
            child: Text(
              "${widget.index}",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 14 : 17,
              ),
            ),
          ),
        ),

        SizedBox(width: gap),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      (widget.data['nome'] ?? "Cliente").toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: nameFontSize,
                      ),
                    ),
                  ),

                  if (widget.data['walkin'] == true)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 8 : 10,
                          vertical: compact ? 4 : 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white),
                        ),
                        child: const Text(
                          "WALK-IN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: compact ? 8 : 10),

              Text(
                (widget.data['servizio'] ?? "").toString(),
                maxLines: compact ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: serviceFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: compact ? 7 : 13),

              widget.infoChips,

              if (telefono.isNotEmpty) ...[
                SizedBox(height: compact ? 8 : 14),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      color: Color(0xFF00C853),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        telefono,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF00C853),
                          fontWeight: FontWeight.w600,
                          fontSize: compact ? 12 : 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        SizedBox(width: compact ? 8 : 10),

        GestureDetector(
          onTap: widget.onDelete,
          child: Container(
            width: deleteSize,
            height: deleteSize,
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(compact ? 16 : 18),
              border: Border.all(
                color: Colors.redAccent.withOpacity(0.18),
              ),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 20,
            ),
          ),
        ),
      ],
    );
  },
),
            ),
          ),
        ),
      ),
    );
  }
}