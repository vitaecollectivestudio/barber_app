import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:barber_app/app_background.dart';

class ClientiPage extends StatefulWidget {
  const ClientiPage({super.key});

  @override
  State<ClientiPage> createState() => _ClientiPageState();
}

class _ClientiPageState extends State<ClientiPage> {

  String search = "";

  @override
  Widget build(BuildContext context) {
    return AppBackground(
  child: Scaffold(
      extendBodyBehindAppBar: true,

      backgroundColor: const Color(0xFF0B0B0B),

      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(92),

  child: ClipRRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 18,
        sigmaY: 18,
      ),

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.72),

          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.04),
            ),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),

        child: SafeArea(
          child: Row(
            children: [

              // 🔙 BACK
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },

                child: Container(
                  width: 46,
                  height: 46,

                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(16),

                    color: Colors.white.withOpacity(0.05),

                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // 🧑 TITLE
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "CLIENTI",

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 4),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('utenti')
                          .snapshots(),

                      builder: (context, snapshot) {

                        final totale =
                            snapshot.data?.docs.length ?? 0;

                        return Text(
                          "$totale clienti registrati",

                          overflow:
                              TextOverflow.ellipsis,

                          style: TextStyle(
                            color:
                                Colors.white.withOpacity(0.55),

                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 👥 ICON
              Container(
                width: 46,
                height: 46,

                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(16),

                  color: Colors.white.withOpacity(0.05),

                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),

                child: const Icon(
                  Icons.people_alt_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
),  



      body: Column(
        children: [
const SizedBox (height:20),
          // 🔍 SEARCH BAR
          Padding(
padding: const EdgeInsets.fromLTRB(16, 84, 16, 18),
            child: Container(
              height: 62,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),

                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: [
                    const Color(0xFF1C1C1C),
                    const Color(0xFF141414),
                  ],
                ),

                border: Border.all(
                  color: Colors.white.withOpacity(0.04),
                ),

                boxShadow: [

                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: TextField(
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),

                onChanged: (v) {
                  setState(() {
                    search = v.toLowerCase();
                  });
                },

                decoration: InputDecoration(
                  border: InputBorder.none,

                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 18),

                  hintText: "Cerca cliente",

                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.30),
                    fontSize: 14,
                  ),

                  prefixIcon: Padding(
                    padding:
                        const EdgeInsets.only(left: 14, right: 10),

                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withOpacity(0.35),
                      size: 22,
                    ),
                  ),

                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 50),
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
                      data['telefono']
                              ?.toString()
                              .toLowerCase() ??
                          '';

                  return nome.contains(search) ||
                      telefono.contains(search);

                }).toList();

                if (utenti.isEmpty) {
                  return const Center(
                    child: Text(
                      "Nessun cliente",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),

                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    30,
                  ),

                  itemCount: utenti.length,

                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),

                  itemBuilder: (context, index) {

                    final user = utenti[index];

                    final data =
                        user.data() as Map<String, dynamic>? ?? {};

                    final nome =
                        data['nome']?.toString() ?? 'Nome';

                    final cognome =
                        data['cognome']?.toString() ?? '';

                    final telefono =
                        data['telefono']?.toString() ?? '';

                    return Container(
                      height: 74,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),

                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(22),

                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,

                          colors: [
                            const Color(0xFF1B1B1B),
                            const Color(0xFF121212),
                          ],
                        ),

                        border: Border.all(
                          color: Colors.white.withOpacity(0.04),
                        ),

                        boxShadow: [

                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),

                          BoxShadow(
                            color:
                                Colors.white.withOpacity(0.015),
                            blurRadius: 1,
                            spreadRadius: 1,
                          ),
                        ],
                      ),

                      child: Row(
                        children: [

                          // 👤 AVATAR
                          Container(
                            width: 42,
                            height: 42,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,

                                colors: [
                                  Colors.white
                                      .withOpacity(0.08),

                                  Colors.white
                                      .withOpacity(0.02),
                                ],
                              ),

                              border: Border.all(
                                color:
                                    Colors.white.withOpacity(0.04),
                              ),
                            ),

                            child: const Icon(
                              Icons.person,
                              color: Colors.white70,
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
                                  overflow:
                                      TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  telefono.isNotEmpty
                                      ? telefono
                                      : "Numero non disponibile",

                                  style: TextStyle(
                                    color: Colors.white
                                        .withOpacity(0.38),

                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 📞 ACTION
                          if (telefono.isNotEmpty)
                            GestureDetector(
                              onTap: () async {

                                final url =
                                    Uri.parse("tel:$telefono");

                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },

                              child: Container(
                                width: 38,
                                height: 38,

                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,

                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white
                                          .withOpacity(0.08),

                                      Colors.white
                                          .withOpacity(0.03),
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
    );
  }
  @override
void dispose() {
  super.dispose();
}
}