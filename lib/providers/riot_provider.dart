import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/riot_api_service.dart';

final riotApiServiceProvider = Provider((ref) => RiotApiService());

class UserStatsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final RiotApiService _apiService;

  UserStatsNotifier(this._apiService) : super(const AsyncValue.loading());

  Future<void> fetchUserStats(String summonerName, String summonerTag) async {
    try {
      print('Fetching user stats for $summonerName#$summonerTag...');
      state = const AsyncValue.loading();
      final stats = await _apiService.getUserStats(summonerName, summonerTag);
      print('Fetched stats: $stats');
      state = AsyncValue.data(stats);
    } catch (e) {
      print('Error fetching user stats: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final userStatsNotifierProvider = StateNotifierProvider<UserStatsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final apiService = ref.watch(riotApiServiceProvider);
  return UserStatsNotifier(apiService);
});
