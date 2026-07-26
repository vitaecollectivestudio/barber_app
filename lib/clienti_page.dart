import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:barber_app/core/responsive/responsive_utils.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ClientiPage extends StatefulWidget {
  const ClientiPage({super.key});

  @override
  State<ClientiPage> createState() => _ClientiPageState();
}

class _ClientiPageState extends State<ClientiPage> {
  String search = "";

  Widget _responsiveDialogShell({
    required BuildContext dialogContext,
    required Widget child,
    double maxWidth = 420,
  }) {
    final media = MediaQuery.of(dialogContext);

    final availableHeight =
        media.size.height - media.padding.top - media.padding.bottom - 48;

    final dialogMaxHeight = availableHeight.clamp(280.0, 720.0).toDouble();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: dialogMaxHeight,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final isTablet = Responsive.isTablet(context);

    final isDesktop = Responsive.isDesktop(context);

    final horizontalPadding = Responsive.horizontalPadding(context);

    final maxWidth = Responsive.maxContentWidth(context);

    return Stack(
      children: [
        // 🌑 BACKGROUND
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,

              colors: [
                Color(0xFFFAFAFA),

                Color(0xFFF1F1F1),

                Color(0xFFE8E8E8),

                Color(0xFFF7F7F7),
              ],
            ),
          ),
        ),

        // ✨ LIGHT
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.2,

                colors: [Colors.white.withOpacity(0.85), Colors.transparent],
              ),
            ),
          ),
        ),

        Scaffold(
          extendBodyBehindAppBar: true,

          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
              isMobile
                  ? 104
                  : isTablet
                  ? 132
                  : 148,
            ),

            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

                child: Container(
                  padding: EdgeInsets.only(
                    left: isMobile ? 14 : 24,
                    right: isMobile ? 14 : 24,
                    top: isMobile ? 8 : 16,
                    bottom: isMobile ? 8 : 12,
                  ),

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,

                      colors: [
                        Colors.black.withOpacity(0.82),

                        const Color(0xFF111111).withOpacity(0.76),

                        Colors.black.withOpacity(0.70),
                      ],
                    ),

                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(isMobile ? 28 : 34),

                      bottomRight: Radius.circular(isMobile ? 28 : 34),
                    ),

                    border: Border.all(color: Colors.white.withOpacity(0.07)),
                  ),

                  child: SafeArea(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },

                          child: Container(
                            width: isMobile ? 54 : 72,
                            height: isMobile ? 54 : 72,

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),

                              color: Colors.white.withOpacity(0.06),

                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),

                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),

                        SizedBox(width: isMobile ? 14 : 20),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 8 : 12,
                            vertical: isMobile ? 4 : 6,
                          ),

                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853).withOpacity(0.12),

                            borderRadius: BorderRadius.circular(30),

                            border: Border.all(
                              color: const Color(0xFF00E676).withOpacity(0.25),
                            ),
                          ),

                          child: FittedBox(
                            fit: BoxFit.scaleDown,

                            child: Row(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: const Color(0xFF69F0AE),
                                  size: isMobile ? 11 : 14,
                                ),

                                SizedBox(width: isMobile ? 4 : 6),

                                Text(
                                  "GESTIONE CLIENTI REGISTRATI",

                                  style: TextStyle(
                                    color: const Color(0xFF69F0AE),

                                    fontSize: isMobile ? 9 : 11,

                                    fontWeight: FontWeight.w700,

                                    letterSpacing: isMobile ? 0.6 : 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          body: SafeArea(
            top: false,

            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop
                      ? 1320
                      : isTablet
                      ? 1000
                      : double.infinity,
                ),

                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // 🔍 SEARCH BAR
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        isMobile ? 90 : 120,
                        horizontalPadding,
                        24,
                      ),
                      child: Container(
                        height: isMobile
                            ? 64
                            : isTablet
                            ? 72
                            : 78,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            isMobile ? 24 : 30,
                          ),

                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,

                            colors: [
                              const Color(0xFF202020),

                              const Color(0xFF171717),

                              const Color(0xFF101010),
                            ],
                          ),

                          border: Border.all(
                            color: Colors.white.withOpacity(0.10),
                          ),

                          boxShadow: [
                            // 🌑 MAIN SHADOW
                            BoxShadow(
                              color: Colors.black.withOpacity(0.38),

                              blurRadius: 42,
                              spreadRadius: 2,

                              offset: const Offset(0, 18),
                            ),

                            // ✨ LIGHT GLOW
                            BoxShadow(
                              color: Colors.white.withOpacity(0.03),

                              blurRadius: 12,
                              spreadRadius: 1,
                            ),

                            // 🔥 DEPTH
                            BoxShadow(
                              color: Colors.black.withOpacity(0.22),

                              blurRadius: 80,
                              spreadRadius: 12,

                              offset: const Offset(0, 30),
                            ),
                          ],
                        ),

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            isMobile ? 24 : 30,
                          ),

                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),

                            child: TextField(
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),

                              onChanged: (v) {
                                setState(() {
                                  search = v.toLowerCase();
                                });
                              },

                              decoration: InputDecoration(
                                border: InputBorder.none,

                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),

                                hintText: "Ricerca cliente",

                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.62),

                                  fontSize: isDesktop
                                      ? 18
                                      : isTablet
                                      ? 16
                                      : 14,
                                ),

                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 14,
                                    right: 10,
                                  ),

                                  child: Icon(
                                    Icons.manage_search_rounded,
                                    color: Colors.white.withOpacity(0.35),

                                    size: isMobile ? 24 : 28,
                                  ),
                                ),

                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 50,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('utenti')
                            .orderBy('nome')
                            .snapshots(),

                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final utenti = snapshot.data!.docs.where((doc) {
                            final data =
                                doc.data() as Map<String, dynamic>? ?? {};

                            final nome =
                                "${data['nome'] ?? ''} ${data['cognome'] ?? ''}"
                                    .toLowerCase();

                            final telefono =
                                data['telefono']?.toString().toLowerCase() ??
                                '';

                            return nome.contains(search) ||
                                telefono.contains(search);
                          }).toList();

                          if (utenti.isEmpty) {
                            return const Center(
                              child: Text(
                                "Nessun cliente",
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          }

                          return ListView.separated(
                            physics: const BouncingScrollPhysics(),

                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              0,
                              horizontalPadding,
                              MediaQuery.of(context).padding.bottom + 40,
                            ),

                            itemCount: utenti.length,

                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),

                            itemBuilder: (context, index) {
                              final user = utenti[index];

                              final data =
                                  user.data() as Map<String, dynamic>? ?? {};

                              final nome = data['nome']?.toString() ?? 'Nome';

                              final cognome = data['cognome']?.toString() ?? '';

                              final telefono =
                                  data['telefono']?.toString() ?? '';

                              return AnimatedContainer(
  duration: const Duration(milliseconds: 180),

  constraints: BoxConstraints(
    minHeight: isDesktop
        ? 102
        : isTablet
        ? 92
        : 86,
  ),

  padding: EdgeInsets.symmetric(
    horizontal: isMobile ? 12 : 16,
    vertical: isMobile ? 12 : 14,
  ),

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    isMobile ? 26 : 34,
                                  ),

                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,

                                    colors: [
                                      Color(0xFF1B1B1B),

                                      Color(0xFF101010),
                                    ],
                                  ),

                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.07),
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.24),

                                      blurRadius: 24,
                                      offset: const Offset(0, 12),
                                    ),

                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.03),

                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),

                                child: Row(
                                  children: [
                                    // 👤 AVATAR
                                    Container(
                                      width: isDesktop
                                          ? 56
                                          : isTablet
                                          ? 50
                                          : 46,

                                      height: isDesktop
                                          ? 56
                                          : isTablet
                                          ? 50
                                          : 46,

                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,

                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,

                                          colors: [
                                            const Color(
                                              0xFF00C853,
                                            ).withOpacity(0.22),

                                            const Color(
                                              0xFF00E676,
                                            ).withOpacity(0.06),
                                          ],
                                        ),

                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.04),
                                        ),
                                      ),

                                      child: const Icon(
                                        Icons.workspace_premium_rounded,
                                        color: const Color(0xFF69F0AE),
                                        size: 20,
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    // 📛 INFO
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,

                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            "$nome $cognome",

                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,

                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isDesktop
                                                  ? 18
                                                  : isTablet
                                                  ? 16
                                                  : 14,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.4,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
  telefono.isNotEmpty
      ? telefono
      : "Numero non disponibile",
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.38,
                                              ),

                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Row(
                                      mainAxisSize: MainAxisSize.min,

                                      children: [
                                        // 📞 CALL
                                        if (telefono.isNotEmpty)
                                          GestureDetector(
                                            onTap: () async {
                                              final url = Uri.parse(
                                                "tel:$telefono",
                                              );

                                              if (await canLaunchUrl(url)) {
                                                await launchUrl(url);
                                              }
                                            },

                                            child: Container(
                                              width: isMobile ? 40 : 44,
                                              height: isMobile ? 40 : 44,

                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,

                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white.withOpacity(
                                                      0.08,
                                                    ),

                                                    Colors.white.withOpacity(
                                                      0.03,
                                                    ),
                                                  ],
                                                ),

                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.04),
                                                ),
                                              ),

                                              child: const Icon(
                                                Icons.call_rounded,
                                                color: Color(0xFF00C853),
                                                size: 16,
                                              ),
                                            ),
                                          ),

                                        if (telefono.isNotEmpty)
  SizedBox(width: isMobile ? 8 : 12),

                                        // 🗑 DELETE
                                        GestureDetector(
                                          onTap: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,

                                              builder: (dialogContext) {
                                                return _responsiveDialogShell(
                                                  dialogContext: dialogContext,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          isMobile ? 34 : 42,
                                                        ),

                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                        sigmaX: 24,
                                                        sigmaY: 24,
                                                      ),

                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                          isMobile ? 22 : 30,
                                                        ),

                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                isMobile
                                                                    ? 34
                                                                    : 42,
                                                              ),

                                                          gradient:
                                                              LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,

                                                                colors: [
                                                                  const Color(
                                                                    0xFF1B1B1B,
                                                                  ),

                                                                  const Color(
                                                                    0xFF111111,
                                                                  ),
                                                                ],
                                                              ),

                                                          border: Border.all(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.08,
                                                                ),
                                                          ),

                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                    0.45,
                                                                  ),

                                                              blurRadius: 50,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    24,
                                                                  ),
                                                            ),

                                                            BoxShadow(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                    0.02,
                                                                  ),

                                                              blurRadius: 12,
                                                              spreadRadius: 1,
                                                            ),
                                                          ],
                                                        ),

                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,

                                                          children: [
                                                            // 🔴 ICON
                                                            Container(
                                                              width: isMobile
                                                                  ? 74
                                                                  : 86,
                                                              height: isMobile
                                                                  ? 74
                                                                  : 86,

                                                              decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,

                                                                gradient: LinearGradient(
                                                                  begin: Alignment
                                                                      .topLeft,
                                                                  end: Alignment
                                                                      .bottomRight,

                                                                  colors: [
                                                                    Colors
                                                                        .redAccent
                                                                        .withOpacity(
                                                                          0.24,
                                                                        ),

                                                                    Colors
                                                                        .redAccent
                                                                        .withOpacity(
                                                                          0.08,
                                                                        ),
                                                                  ],
                                                                ),

                                                                border: Border.all(
                                                                  color: Colors
                                                                      .redAccent
                                                                      .withOpacity(
                                                                        0.24,
                                                                      ),
                                                                ),
                                                              ),

                                                              child: const Icon(
                                                                Icons
                                                                    .delete_forever_rounded,
                                                                color: Colors
                                                                    .redAccent,
                                                                size: 34,
                                                              ),
                                                            ),

                                                            SizedBox(
                                                              height: isMobile
                                                                  ? 20
                                                                  : 28,
                                                            ),

                                                            // 🧠 TITLE
                                                            Text(
                                                              "ELIMINA ACCOUNT",

                                                              textAlign:
                                                                  TextAlign
                                                                      .center,

                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,

                                                                fontSize:
                                                                    isMobile
                                                                    ? 20
                                                                    : 24,

                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,

                                                                letterSpacing:
                                                                    1.6,
                                                              ),
                                                            ),

                                                            SizedBox(
                                                              height: isMobile
                                                                  ? 10
                                                                  : 14,
                                                            ),

                                                            // 📝 DESCRIPTION
                                                            Text(
                                                              "Vuoi eliminare definitivamente l'account di $nome?",

                                                              textAlign:
                                                                  TextAlign
                                                                      .center,

                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                      0.68,
                                                                    ),

                                                                fontSize:
                                                                    isMobile
                                                                    ? 13
                                                                    : 15,

                                                                height: 1.5,

                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),

                                                            SizedBox(
                                                              height: isMobile
                                                                  ? 28
                                                                  : 36,
                                                            ),

                                                            // 🔘 ACTIONS
                                                            Row(
                                                              children: [
                                                                // CANCEL
                                                                Expanded(
                                                                  child: GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.of(
                                                                        dialogContext,
                                                                      ).pop(
                                                                        false,
                                                                      );
                                                                    },

                                                                    child: Container(
                                                                      height:
                                                                          isMobile
                                                                          ? 54
                                                                          : 60,

                                                                      decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              22,
                                                                            ),

                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(
                                                                              0.05,
                                                                            ),

                                                                        border: Border.all(
                                                                          color: Colors.white.withOpacity(
                                                                            0.05,
                                                                          ),
                                                                        ),
                                                                      ),

                                                                      child: Center(
                                                                        child: Text(
                                                                          "ANNULLA",

                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.white,

                                                                            fontSize:
                                                                                isMobile
                                                                                ? 13
                                                                                : 15,

                                                                            fontWeight:
                                                                                FontWeight.w700,

                                                                            letterSpacing:
                                                                                1,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),

                                                                SizedBox(
                                                                  width:
                                                                      isMobile
                                                                      ? 12
                                                                      : 16,
                                                                ),

                                                                // DELETE
                                                                Expanded(
                                                                  child: GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.of(
                                                                        dialogContext,
                                                                      ).pop(
                                                                        true,
                                                                      );
                                                                    },

                                                                    child: Container(
                                                                      height:
                                                                          isMobile
                                                                          ? 54
                                                                          : 60,

                                                                      decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              22,
                                                                            ),

                                                                        gradient: LinearGradient(
                                                                          begin:
                                                                              Alignment.topLeft,
                                                                          end: Alignment
                                                                              .bottomRight,

                                                                          colors: [
                                                                            Colors.redAccent.withOpacity(
                                                                              0.90,
                                                                            ),

                                                                            Colors.red.withOpacity(
                                                                              0.75,
                                                                            ),
                                                                          ],
                                                                        ),

                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color: Colors.redAccent.withOpacity(
                                                                              0.28,
                                                                            ),

                                                                            blurRadius:
                                                                                24,
                                                                            offset: const Offset(
                                                                              0,
                                                                              10,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),

                                                                      child: Center(
                                                                        child: Text(
                                                                          "ELIMINA",

                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.white,

                                                                            fontSize:
                                                                                isMobile
                                                                                ? 13
                                                                                : 15,

                                                                            fontWeight:
                                                                                FontWeight.w800,

                                                                            letterSpacing:
                                                                                1.2,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );

                                            if (confirm == true) {
                                              try {
                                                await FirebaseFunctions.instance
                                                    .httpsCallable(
                                                      'deleteClientAccount',
                                                    )
                                                    .call({"uid": user.id});

                                                if (!mounted) return;

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Cliente eliminato correttamente",
                                                    ),
                                                  ),
                                                );
                                              } on FirebaseFunctionsException catch (
                                                e
                                              ) {
                                                if (!mounted) return;

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      e.message ??
                                                          "Errore eliminazione cliente",
                                                    ),
                                                  ),
                                                );
                                              } catch (e) {
                                                if (!mounted) return;

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Errore imprevisto",
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },

                                          child: Container(
                                            width: isMobile ? 40 : 44,
                                            height: isMobile ? 40 : 44,

                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,

                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.redAccent.withOpacity(
                                                    0.18,
                                                  ),

                                                  Colors.redAccent.withOpacity(
                                                    0.06,
                                                  ),
                                                ],
                                              ),

                                              border: Border.all(
                                                color: Colors.redAccent
                                                    .withOpacity(0.18),
                                              ),
                                            ),

                                            child: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.redAccent,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
