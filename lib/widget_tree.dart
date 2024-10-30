import 'package:nexus_now/auth.dart';
import 'package:nexus_now/pages/login_register_page.dart';
import 'package:flutter/material.dart';
import 'package:nexus_now/main_screen.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MainScreen();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}