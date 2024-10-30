import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EsportWidget extends StatefulWidget {
  final String apiKey = "1F_9zjgEe5OzZCYqFx3YWxmLPC2if-_7MRXJSBG70zaFyR_6ttI";

  @override
  _EsportWidgetState createState() => _EsportWidgetState();
}

class _EsportWidgetState extends State<EsportWidget> {
  Future<Map<String, dynamic>?> _fetchTeamData(String teamId) async {
    final response = await http.get(
      Uri.parse("https://api.pandascore.co/lol/teams?filter[id]=$teamId"),
      headers: {"Authorization": "Bearer ${widget.apiKey}"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)[0];
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchPlayerData(String playerId) async {
    final response = await http.get(
      Uri.parse("https://api.pandascore.co/lol/players?filter[id]=$playerId"),
      headers: {"Authorization": "Bearer ${widget.apiKey}"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)[0];
    }
    return null;
  }

  void _showSearchDialog(BuildContext context, String title, String searchType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SearchDialog(
          title: title,
          searchType: searchType,
          apiKey: widget.apiKey,
          onFavoriteSaved: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, String title, String id, String type, {String? currentName}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SearchDialog(
          title: title,
          searchType: type,
          apiKey: widget.apiKey,
          currentName: currentName,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text("Utilisateur non connecté"));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('esport').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Column(
            children: [
              _buildAddTeamButton(),
              _buildAddPlayerButton(),
            ],
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final favTeamId = data['fav-team_esport'];
        final favPlayerId = data['fav-player_esport'];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "E-sport",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text("Mon équipe favorite", style: TextStyle(fontSize: 16, color: Colors.white)),
              favTeamId != null ? _buildFavoriteTeamCard(favTeamId) : _buildAddTeamButton(),
              SizedBox(height: 16),
              Text("Mon joueur favori", style: TextStyle(fontSize: 16, color: Colors.white)),
              favPlayerId != null ? _buildFavoritePlayerCard(favPlayerId) : _buildAddPlayerButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoriteTeamCard(String favTeamId) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchTeamData(favTeamId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          final teamData = snapshot.data!;
          return Card(
            child: ListTile(
              leading: teamData['image_url'] != null
                  ? Image.network(teamData['image_url'], width: 50, height: 50, fit: BoxFit.cover)
                  : Container(width: 50, height: 50, color: Colors.grey),
              title: Text(teamData['name'] ?? ''),
              subtitle: Text(teamData['location'] ?? ''),
              trailing: Icon(Icons.edit),
              onTap: () => _showEditDialog(context, "Modifier mon équipe favorite", favTeamId, "team"),
            ),
          );
        }
        return Text("Aucune équipe trouvée");
      },
    );
  }

  Widget _buildFavoritePlayerCard(String favPlayerId) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchPlayerData(favPlayerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          final playerData = snapshot.data!;
          return Card(
            child: ListTile(
              leading: playerData['image_url'] != null
                  ? Image.network(playerData['image_url'], width: 50, height: 50, fit: BoxFit.cover)
                  : Container(width: 50, height: 50, color: Colors.grey),
              title: Text(playerData['name'] ?? ''),
              subtitle: Text(playerData['current_team']?['name'] ?? ''),
              trailing: Icon(Icons.edit),
              onTap: () => _showEditDialog(context, "Modifier mon joueur favori", favPlayerId, "player"),
            ),
          );
        }
        return Text("Aucun joueur trouvé");
      },
    );
  }

  Widget _buildAddTeamButton() {
    return TextButton(
      onPressed: () => _showSearchDialog(context, "Ajouter mon équipe favorite", "team"),
      child: Text("Ajouter mon équipe favorite", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildAddPlayerButton() {
    return TextButton(
      onPressed: () => _showSearchDialog(context, "Ajouter mon joueur favori", "player"),
      child: Text("Ajouter mon joueur favori", style: TextStyle(color: Colors.white)),
    );
  }
}

class SearchDialog extends StatefulWidget {
  final String title;
  final String searchType;
  final String apiKey;
  final String? currentName;
  final Function()? onFavoriteSaved;

  SearchDialog({
    required this.title,
    required this.searchType,
    required this.apiKey,
    this.currentName,
    this.onFavoriteSaved,
  });

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  List<dynamic> searchResults = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.currentName != null) {
      _searchController.text = widget.currentName!;
    }
  }

  Future<void> _search() async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
      searchResults.clear();
    });

    final apiUrl = widget.searchType == "team"
        ? "https://api.pandascore.co/lol/teams?search[name]=$query"
        : "https://api.pandascore.co/lol/players?search[name]=$query";

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {"Authorization": "Bearer ${widget.apiKey}"},
    );

    if (response.statusCode == 200) {
      setState(() {
        searchResults = json.decode(response.body);
      });
    } else {
      print("Erreur lors de la recherche: ${response.statusCode}");
    }

    setState(() {
      isLoading = false;
    });
  }

Future<void> _saveFavorite(String id) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final docRef = FirebaseFirestore.instance.collection('esport').doc(user.uid);
  final favField = widget.searchType == "team" ? "fav-team_esport" : "fav-player_esport";

  await docRef.set({favField: id}, SetOptions(merge: true));

  if (widget.onFavoriteSaved != null) {
    widget.onFavoriteSaved!();
  } else {
    Navigator.of(context).pop();
  }
}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(labelText: "Rechercher..."),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: isLoading ? null : _search,
            child: isLoading ? CircularProgressIndicator() : Text("Rechercher"),
          ),
          if (searchResults.isNotEmpty) ...[
            SizedBox(height: 16),
            Text("Résultats de recherche"),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final result = searchResults[index];
                  return ListTile(
                    title: Text(result['name']),
                    onTap: () => _saveFavorite(result['id'].toString()),
                  );
                },
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Fermer"),
        ),
      ],
    );
  }
}
