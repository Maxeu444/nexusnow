import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexus_now/widgets/user_stats_widget.dart';

class StatsPage extends StatelessWidget {
  StatsPage({Key? key}) : super(key: key);

  final User? user = FirebaseAuth.instance.currentUser;

  Future<Map<String, String>> _fetchUserData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final pseudo = data?['pseudo_user'] ?? 'Unknown';
        final tag = data?['tag_user'] ?? 'Unknown';
        return {'pseudo': pseudo, 'tag': tag};
      }
    }
    return {'pseudo': 'Unknown', 'tag': 'Unknown'};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes stats'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Erreur lors de la récupération des données"));
          } else if (snapshot.hasData) {
            final userData = snapshot.data!;
            return Container(
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: const Color.fromRGBO(36, 36, 36, 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  UserStatsWidget(
                    summonerName: userData['pseudo']!,
                    summonerTag: userData['tag']!,
                    isHomePage: false,
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text("Pas de données disponibles"));
          }
        },
      ),
    );
  }
}
