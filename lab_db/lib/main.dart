import 'package:flutter/material.dart';
import 'ex1_shared_preferences.dart';
import 'ex2_remote_api_model.dart';
import 'ex3_async_ui_states.dart';
import 'ex4_sqlite_crud.dart';
import 'ex5_offline_first_repo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isDark = await SettingsService.loadThemeMode();
  runApp(MobileDataStorageLabApp(initialDarkMode: isDark));
}

class MobileDataStorageLabApp extends StatefulWidget {
  final bool initialDarkMode;

  const MobileDataStorageLabApp({Key? key, required this.initialDarkMode}) : super(key: key);

  @override
  State<MobileDataStorageLabApp> createState() => _MobileDataStorageLabAppState();
}

class _MobileDataStorageLabAppState extends State<MobileDataStorageLabApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  void _updateTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PRM393 - Mobile Data Storage Lab',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blueAccent,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blueAccent,
        useMaterial3: true,
      ),
      home: LabMenuScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: _updateTheme,
      ),
    );
  }
}

class LabMenuScreen extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const LabMenuScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final exercises = [
      {
        'title': 'Exercise 1 – SharedPreferences',
        'subtitle': 'Lưu trữ Key-Value: Cài đặt, Theme Mode & Cờ trạng thái (Slide 8, 9)',
        'icon': Icons.tune,
        'color': Colors.teal,
        'page': Ex1SharedPreferencesScreen(onThemeChanged: onThemeChanged),
      },
      {
        'title': 'Exercise 2 – REST API & Model',
        'subtitle': 'Kiến trúc Remote DB, gọi HTTP GET/POST & Typed Dart Model (Slide 3, 4)',
        'icon': Icons.http,
        'color': Colors.indigo,
        'page': const Ex2RemoteApiModelScreen(),
      },
      {
        'title': 'Exercise 3 – FutureBuilder Async UI',
        'subtitle': 'Một Future, ba trạng thái giao diện: Loading, Error & Success (Slide 5)',
        'icon': Icons.hourglass_top,
        'color': Colors.orange,
        'page': const Ex3AsyncUiStatesScreen(),
      },
      {
        'title': 'Exercise 4 – SQLite Local CRUD',
        'subtitle': 'Lưu trữ quan hệ cục bộ: Hỗ trợ ACID, CRUD với sqflite (Slide 8, 9)',
        'icon': Icons.storage,
        'color': Colors.green,
        'page': const Ex4SqliteCrudScreen(),
      },
      {
        'title': 'Exercise 5 – Offline-First & Repository',
        'subtitle': 'Local-First, Sync Queue, Cloud Sync & Repository Pattern (Slide 10, 11)',
        'icon': Icons.cloud_sync,
        'color': Colors.purple,
        'page': const Ex5OfflineFirstRepoScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Data Storage Practice Lab'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Chuyển Theme',
            onPressed: () {
              final newTheme = !isDarkMode;
              SettingsService.saveThemeMode(newTheme);
              onThemeChanged(newTheme);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRM393 – Mobile Data Storage',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Remote Database • Local Storage • Offline-First (Module 8 & Module 9)\n'
                    'Chọn từng bài tập dưới đây để thực hành và kiểm tra kết quả:',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...exercises.map((ex) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (ex['color'] as Color).withValues(alpha: 0.15),
                  child: Icon(ex['icon'] as IconData, color: ex['color'] as Color),
                ),
                title: Text(
                  ex['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(ex['subtitle'] as String),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ex['page'] as Widget),
                  );
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
