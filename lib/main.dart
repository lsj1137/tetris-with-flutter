import 'package:flutter/material.dart';

import 'screens/main_menu_screen.dart';

void main() {
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tetris',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
      ),
      home: const MainMenuScreen(),
    );
  }
}
