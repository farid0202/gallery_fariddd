import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: SettingsPage(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const SettingsPage({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme Mode'),
            subtitle: Text(isDarkMode ? 'Dark Mode' : 'Light Mode'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) => toggleTheme(),
            ),
          ),
        ],
      ),
    );
  }
}
