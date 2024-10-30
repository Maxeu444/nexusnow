import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/esport_service.dart';
import '../providers/esport_notifier.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchDialog extends ConsumerWidget {
  final String title;
  final String searchType;
  final Function()? onFavoriteSaved;

  SearchDialog({required this.title, required this.searchType, this.onFavoriteSaved});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = TextEditingController();
    List<dynamic> searchResults = [];
    bool isLoading = false;

    Future<void> _search() async {
      final query = searchController.text;
      if (query.isEmpty) return;

      isLoading = true;
      try {
        final apiUrl = searchType == "team"
            ? "https://api.pandascore.co/lol/teams?search[name]=$query"
            : "https://api.pandascore.co/lol/players?search[name]=$query";

        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            "Authorization": "Bearer ${EsportService().apiKey}",
          },
        );

        if (response.statusCode == 200) {
          searchResults = json.decode(response.body);
        }
      } catch (e) {
        print("Erreur de recherche: $e");
      } finally {
        isLoading = false;
      }
    }

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(labelText: 'Nom'),
          ),
          SizedBox(height: 8),
          if (isLoading) CircularProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final item = searchResults[index];
                return ListTile(
                  title: Text(item['name']),
                  onTap: () async {
                    await ref.read(esportNotifierProvider.notifier).updateFavorite(item['id'], searchType);
                    onFavoriteSaved?.call();
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _search();
          },
          child: Text('Rechercher'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Annuler'),
        ),
      ],
    );
  }
}
