import 'dart:convert';
import 'package:http/http.dart' as http;

class RiotApiService {
  final String apiKey = 'RGAPI-332362ff-0f8f-4fc8-b247-772adf88a2c4';
  final String region = 'europe';

  Future<Map<String, dynamic>> getUserStats(String summonerName, String summonerTag, {int retries = 0}) async {
    if (retries > 5) {
      throw Exception('Max retries exceeded');
    }
  
    final puuidUrl = Uri.parse('https://$region.api.riotgames.com/riot/account/v1/accounts/by-riot-id/$summonerName/$summonerTag?api_key=$apiKey');
    final summonerPuuidResponse = await http.get(puuidUrl);
  
    if (summonerPuuidResponse.statusCode == 429) {
      await Future.delayed(Duration(seconds: 1));
      return await getUserStats(summonerName, summonerTag, retries: retries + 1);
    } else if (summonerPuuidResponse.statusCode != 200) {
      throw Exception('Failed to load summoner puuid with sum name');
    }
  
    final summonerPuuidData = jsonDecode(summonerPuuidResponse.body);
    final summonerPuuid = summonerPuuidData['puuid'];

    final summonerUrl = Uri.parse('https://euw1.api.riotgames.com/lol/summoner/v4/summoners/by-puuid/$summonerPuuid?api_key=$apiKey');
    final summonerResponse = await http.get(summonerUrl);
  
    if (summonerResponse.statusCode == 429) {
      await Future.delayed(Duration(seconds: 1));
      return await getUserStats(summonerName, summonerTag, retries: retries + 1);
    } else if (summonerResponse.statusCode != 200) {
      throw Exception('Failed to load summoner with puuid');
    }
  
    final summonerData = jsonDecode(summonerResponse.body);
    final summonerId = summonerData['id'];
  
    final statsUrl = Uri.parse('https://euw1.api.riotgames.com/lol/league/v4/entries/by-summoner/$summonerId?api_key=$apiKey');
    final statsResponse = await http.get(statsUrl);
  
    if (statsResponse.statusCode == 429) {
      await Future.delayed(Duration(seconds: 1));
      return await getUserStats(summonerName, summonerTag, retries: retries + 1);
    } else if (statsResponse.statusCode != 200) {
      throw Exception('Failed to load stats');
    }
  
    final statsData = jsonDecode(statsResponse.body);
    return statsData.isNotEmpty ? statsData[0] : {};
  }

}
