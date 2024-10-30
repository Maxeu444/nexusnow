import 'package:flutter/material.dart';
import 'package:nexus_now/pages/home_page.dart';  // ta page d'accueil
import 'package:nexus_now/pages/esport_page.dart';  // ta page des favoris
import 'package:nexus_now/pages/my_stat_page.dart';  // ta page de profil
import 'package:nexus_now/pages/profil_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [HomePage(), EsportPage(), StatsPage(), ProfilPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 17, 17, 17),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          child: GNav(
            backgroundColor: const Color.fromARGB(255, 17, 17, 17),
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundGradient: LinearGradient(
              colors: [Colors.black, const Color.fromARGB(255, 29, 29, 29)!, const Color.fromARGB(255, 44, 44, 44)!],
            ),
            gap: 8,
            onTabChange: (index) {
              _onItemTapped(index);
            },
            padding: EdgeInsets.all(16),
            tabs: const [
              GButton(icon: Icons.home,
              text: 'Accueil'),
              GButton(icon: Icons.emoji_events,
              text: 'Esport'),
              GButton(icon: Icons.leaderboard,
              text: 'Mes stats'),
              GButton(icon: Icons.person,
              text: 'Profil'),
            ],
          ),
        ),
      )
    );
  }
}
