import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EsportService {
  final String apiKey = "1F_9zjgEe5OzZCYqFx3YWxmLPC2if-_7MRXJSBG70zaFyR_6ttI";

  Future<Map<String, dynamic>?> fetchTeamDetails(String teamId) async {
    final response = await http.get(
      Uri.parse("https://api.pandascore.co/lol/teams?filter[id]=$teamId"),
      headers: {"Authorization": "Bearer $apiKey"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> dataResponse = json.decode(response.body);
      return dataResponse.isNotEmpty ? dataResponse[0] : null;
    }
    throw Exception("Erreur lors de la récupération des détails de l'équipe");
  }

  Future<Map<String, dynamic>?> fetchPlayerDetails(String playerId) async {
    final response = await http.get(
      Uri.parse("https://api.pandascore.co/lol/players?filter[id]=$playerId"),
      headers: {"Authorization": "Bearer $apiKey"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> dataResponse = json.decode(response.body);
      return dataResponse.isNotEmpty ? dataResponse[0] : null;
    }
    throw Exception("Erreur lors de la récupération des détails du joueur");
  }

  Future<void> saveFavorite(String id, String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final favField = type == "team" ? "fav-team_esport" : "fav-player_esport";

    final docRef = FirebaseFirestore.instance.collection('esport').doc(userId);
    await docRef.set({favField: id}, SetOptions(merge: true));
  }

  Future<Map<String, String?>> fetchFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    final doc = await FirebaseFirestore.instance.collection('esport').doc(user.uid).get();
    return doc.exists ? doc.data() as Map<String, String?> : {};
  }
}
