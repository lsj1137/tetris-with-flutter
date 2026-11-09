import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  static const List<(IconData, String, String)> _items = [
    (Icons.tag, 'Version', '1.0.1'),
    (Icons.event, 'Date', '2023.07.02'),
    (Icons.person_outline, 'Name', 'SeJun Lim'),
    (Icons.code, 'Github', 'https://github.com/WaRoong2'),
    (Icons.mail_outline, 'Email', 'lsj1137jsl@gmail.com'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Info')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (icon, title, value) in _items)
            ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: SelectableText(value),
            ),
        ],
      ),
    );
  }
}
