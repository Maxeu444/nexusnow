import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/riot_provider.dart';

class UserStatsWidget extends ConsumerStatefulWidget {
  final String summonerName;
  final String summonerTag;

  UserStatsWidget({required this.summonerName, required this.summonerTag});

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
              
              // // Section des champions
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: data['champions'].map<Widget>((champ) {
              //       return Container(
              //         margin: EdgeInsets.only(right: 8.0),
              //         padding: EdgeInsets.all(8.0),
              //         decoration: BoxDecoration(
              //           color: Colors.grey[900],
              //           borderRadius: BorderRadius.circular(8.0),
              //         ),
              //         child: Column(
              //           children: [
              //             Container(
              //               width: 40,
              //               height: 40,
              //               color: Colors.red, // Placeholder color for champion image
              //               child: Icon(Icons.person, color: Colors.white), // Placeholder icon
              //             ),
              //             SizedBox(height: 4),
              //             Text(
              //               champ['name'],
              //               style: TextStyle(color: Colors.white, fontSize: 12),
              //             ),
              //             Text(
              //               '${champ['wins']}V / ${champ['losses']}D',
              //               style: TextStyle(
              //                 color: Colors.green,
              //                 fontSize: 12,
              //               ),
              //             ),
              //           ],
              //         ),
              //       );
              //     }).toList(),
              //   ),
              // ),
              
              // SizedBox(height: 16),

              // Section des statistiques classées
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
                  color: winRate >= 50 ? Colors.green : Colors.red,
                ),
              ),
              Text(
                '$gamesPlayed games - $wins V / $losses D',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: 16),

              // Bouton Voir plus
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Action pour voir plus
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
