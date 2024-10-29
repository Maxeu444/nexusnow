import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus_now/auth.dart';
import 'package:flutter/material.dart';
import 'package:nexus_now/widgets/user_stats_widget.dart';

class HomePage extends StatelessWidget{
  HomePage({Key? key}) : super(key: key);

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title(){
    return const Text('Accueil');
  }

  Widget _userUid(){
    return Text(user?.email ?? 'User email');
  }

  Widget _signOutButton(){
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign out'),
    );
  } 

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: const Color.fromRGBO(36, 36, 36, 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            UserStatsWidget(summonerName: 'Maxeu444', summonerTag: 'EUW'),
            _signOutButton()
          ],
        ),
      ),
    );
  }
}