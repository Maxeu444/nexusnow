import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/esport_service.dart';

class EsportNotifier extends StateNotifier<Map<String, dynamic>> {
  final EsportService esportService;
  
  EsportNotifier(this.esportService) : super({});

  Future<void> loadFavorites() async {
    final favorites = await esportService.fetchFavorites();
    state = favorites;

    if (favorites['fav-team_esport'] != null) {
      final teamDetails = await esportService.fetchTeamDetails(favorites['fav-team_esport']!);
      state['favTeam'] = teamDetails;
    }

    if (favorites['fav-player_esport'] != null) {
      final playerDetails = await esportService.fetchPlayerDetails(favorites['fav-player_esport']!);
      state['favPlayer'] = playerDetails;
    }
  }

  Future<void> updateFavorite(String id, String type) async {
    await esportService.saveFavorite(id, type);
    await loadFavorites();
  }
}

final esportNotifierProvider = StateNotifierProvider<EsportNotifier, Map<String, dynamic>>((ref) {
  return EsportNotifier(EsportService());
});
