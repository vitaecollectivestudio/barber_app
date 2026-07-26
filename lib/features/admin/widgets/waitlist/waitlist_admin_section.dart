import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:barber_app/features/admin/services/waitlist_admin_service.dart';

class WaitlistAdminSection extends StatelessWidget {
  final DateTime selectedDay;
  final String selectedOperator;
  final bool isMobile;

  const WaitlistAdminSection({
    super.key,
    required this.selectedDay,
    required this.selectedOperator,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: WaitlistAdminService.waitlistForDay(day: selectedDay),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _sectionShell(
            child: const Text(
              "Errore caricamento lista d'attesa.",
              style: TextStyle(color: Colors.redAccent),
            ),
          );
        }

        if (!snapshot.hasData) {
          return _sectionShell(
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF69F0AE),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data();

          if (selectedOperator == "Tutti") {
            return true;
          }

          return (data['operatore'] ?? '').toString().toLowerCase() ==
              selectedOperator.toLowerCase();
        }).toList();

        docs.sort((a, b) {
          final aData = a.data();
          final bData = b.data();

          final aTime = aData['creatoIl'];
          final bTime = bData['creatoIl'];

          if (aTime is! Timestamp || bTime is! Timestamp) {
            return 0;
          }

          return aTime.compareTo(bTime);
        });

        return _sectionShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(docs.length),

              const SizedBox(height: 18),

              if (docs.isEmpty)
                _emptyState()
              else
                Column(
                  children: docs.map((doc) {
                    return _WaitlistCard(
                      waitlistId: doc.id,
                      data: doc.data(),
                      isMobile: isMobile,
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionShell({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 28 : 36),
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
            color: Colors.black.withOpacity(0.45),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: const Color(0xFF00C853).withOpacity(0.05),
            blurRadius: 24,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _header(int count) {
  return Row(
    children: [
      Container(
        width: isMobile ? 42 : 48,
        height: isMobile ? 42 : 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF242424),
              Color(0xFF111111),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.30),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.hourglass_top_rounded,
          color: Color(0xFFD4AF37),
          size: 21,
        ),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "LISTA D'ATTESA",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 1.4,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              count == 1
                  ? "1 cliente in attesa"
                  : "$count clienti in attesa",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.50),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),

      Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.045),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withOpacity(0.07),
          ),
        ),
        child: Text(
          DateFormat('dd/MM').format(selectedDay),
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ),
    ],
  );
}

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: const Text(
        "Nessun cliente in lista d'attesa per questo giorno.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _WaitlistCard extends StatelessWidget {
  final String waitlistId;
  final Map<String, dynamic> data;
  final bool isMobile;

  const _WaitlistCard({
    required this.waitlistId,
    required this.data,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final userId = data['userId']?.toString() ?? '';
    final servizio = data['servizio']?.toString() ?? 'Servizio';
    final operatore = data['operatore']?.toString() ?? '-';
    final notified = data['notified'] == true;
    final notifyError = data['notifyError']?.toString();

    final createdAt = data['creatoIl'] is Timestamp
        ? (data['creatoIl'] as Timestamp).toDate()
        : null;

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: userId.isEmpty
          ? null
          : WaitlistAdminService.userDoc(userId),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data();

        final nome = userData == null
            ? "Cliente"
            : "${userData['nome'] ?? ''} ${userData['cognome'] ?? ''}".trim();

        final telefono = userData?['telefono']?.toString() ?? '';

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(isMobile ? 14 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.045),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.35),
                      border: Border.all(
                        color: const Color(0xFF69F0AE).withOpacity(0.20),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF69F0AE),
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nome.isEmpty ? "Cliente" : nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          telefono.isEmpty ? "Telefono non disponibile" : telefono,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.48),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),



                  _statusChip(
                    notified: notified,
                    notifyError: notifyError,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _infoChip(
                    icon: Icons.content_cut_rounded,
                    text: servizio,
                  ),
                  _infoChip(
                    icon: Icons.person_rounded,
                    text: operatore,
                  ),
                  if (createdAt != null)
                    _infoChip(
                      icon: Icons.schedule_rounded,
                      text: DateFormat('dd/MM HH:mm').format(createdAt),
                    ),
                ],
              ),


            ],
          ),
        );
      },
    );
  }


  Widget _statusChip({
  required bool notified,
  required String? notifyError,
}) {
  const color = Color(0xFFD4AF37);

  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 7,
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: color.withOpacity(0.30),
      ),
    ),
    child: const Text(
      "IN ATTESA",
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.9,
      ),
    ),
  );
}


  Widget _infoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.26),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.55),
            size: 15,
          ),

          const SizedBox(width: 7),

          Flexible(
  child: Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      color: Colors.white.withOpacity(0.72),
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
    ),
  ),
),
        ],
      ),
    );
  }
}