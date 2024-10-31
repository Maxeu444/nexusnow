import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/riot_provider.dart';

class UserStatsWidget extends ConsumerStatefulWidget {
  final String summonerName;
  final String summonerTag;
  final bool isHomePage;

  UserStatsWidget({
    required this.summonerName,
    required this.summonerTag,
    this.isHomePage = false,
  });

  @override
  _UserStatsWidgetState createState() => _UserStatsWidgetState();
}

class _UserStatsWidgetState extends ConsumerState<UserStatsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userStatsNotifierProvider.notifier).fetchUserStats(widget.summonerName, widget.summonerTag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userStats = ref.watch(userStatsNotifierProvider);

    return userStats.when(
      data: (data) {
        if (data.isEmpty) {
          return Text('No data available');
        }
        
        String rank = data['tier'] + ' ' + data['rank'];
        double winRate = (data['wins'] / (data['wins'] + data['losses'])) * 100;
        int gamesPlayed = data['wins'] + data['losses'];
        int wins = data['wins'];
        int losses = data['losses'];

        return Container(
          color: const Color.fromRGBO(36, 36, 36, 1),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mes statistiques',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              
              Text(
                'Ranked',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text('$rank ${data['leaguePoints']}LP',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              Text(
                '${winRate.toStringAsFixed(1)}% winrate',
                style: TextStyle(
                  color: winRate >= 40 ? Colors.green : Colors.red,
                ),
              ),
              Text(
                '$gamesPlayed games - $wins V / $losses D',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: 16),

              if (widget.isHomePage) 
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Voir plus',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
