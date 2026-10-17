import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// EXERCISE 1: KEY-VALUE STORAGE WITH SHAREDPREFERENCES
/// References: Slide 8 (SharedPreferences) & Slide 9 (When to use SharedPreferences)
/// Goal: Manage lightweight user preferences (Theme, sync flag, user name) without a heavy DB.

class SettingsService {
  static const String keyDarkMode = 'is_dark_mode';
  static const String keyUserName = 'user_name';
  static const String keyLastSync = 'last_sync_time';

  // Save dark mode setting
  static Future<void> saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyDarkMode, isDark);
  }

  // Load dark mode setting
  static Future<bool> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyDarkMode) ?? false;
  }

  // Save user name
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserName, name);
  }

  // Load user name
  static Future<String> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserName) ?? 'Student';
  }

  // Save last sync timestamp
  static Future<void> saveLastSyncTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastSync, time);
  }

  // Load last sync timestamp
  static Future<String> loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLastSync) ?? 'Chưa đồng bộ';
  }
}

class Ex1SharedPreferencesScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;

  const Ex1SharedPreferencesScreen({Key? key, this.onThemeChanged}) : super(key: key);

  @override
  State<Ex1SharedPreferencesScreen> createState() => _Ex1SharedPreferencesScreenState();
}

class _Ex1SharedPreferencesScreenState extends State<Ex1SharedPreferencesScreen> {
  bool _isDarkMode = false;
  String _userName = '';
  String _lastSync = '';
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final isDark = await SettingsService.loadThemeMode();
    final name = await SettingsService.loadUserName();
    final lastSync = await SettingsService.loadLastSyncTime();

    setState(() {
      _isDarkMode = isDark;
      _userName = name;
      _nameController.text = name;
      _lastSync = lastSync;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _isDarkMode = value);
    await SettingsService.saveThemeMode(value);
    widget.onThemeChanged?.call(value);
  }

  Future<void> _saveUserName() async {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      await SettingsService.saveUserName(newName);
      setState(() => _userName = newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu tên vào SharedPreferences!')),
        );
      }
    }
  }

  Future<void> _updateSyncTimestamp() async {
    final now = DateTime.now().toLocal().toString().split('.')[0];
    await SettingsService.saveLastSyncTime(now);
    setState(() => _lastSync = now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 1: SharedPreferences'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Xin chào, $_userName!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text(
                      '💡 Bài học từ Slide 8 & 9:\n'
                      'SharedPreferences phù hợp nhất để lưu trữ Cài đặt (Settings), Theme, Cờ trạng thái (Flags) và Token. '
                      'Không nên dùng SharedPreferences cho dữ liệu quan hệ hoặc danh sách lớn.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dark Mode (Giao diện tối)'),
              subtitle: Text(_isDarkMode ? 'Đang bật' : 'Đang tắt'),
              value: _isDarkMode,
              onChanged: _toggleDarkMode,
              secondary: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Tên người dùng (Key-Value String):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nhập tên của bạn',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveUserName,
                  child: const Text('Lưu'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Lần đồng bộ gần nhất:'),
              subtitle: Text(_lastSync),
              trailing: ElevatedButton(
                onPressed: _updateSyncTimestamp,
                child: const Text('Cập nhật mốc Sync'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
