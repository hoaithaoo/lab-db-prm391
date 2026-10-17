import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/task_item.dart';
import 'ex4_sqlite_crud.dart';

/// EXERCISE 5: OFFLINE-FIRST ARCHITECTURE & REPOSITORY PATTERN
/// References:
/// - Slide 10: Offline-First Architecture
///   "User Action -> SQLite Local (UI cập nhật ngay) -> Sync Queue -> Online -> Cloud API"
///   "Local-First: Dữ liệu được lưu và phản hồi ngay trên thiết bị"
///   "Background Sync: Tự động đồng bộ khi có mạng"
/// - Slide 11: Best Practices & Kết luận
///   "Widget UI -> Repository / Service (Lớp trung gian) -> [ SQLite / Cloud API ]"
///   "Remote = Sync, Local = Speed, Offline-First = Better UX"

class TaskRepository {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  bool isOnlineSimulated = true;

  // 1. LOCAL-FIRST READ (Slide 10 & 11)
  Future<List<TaskItem>> getTasks() async {
    final localTasks = await dbHelper.getAllTasks();
    if (localTasks.isNotEmpty) {
      return localTasks;
    }

    // Nếu Local rỗng và có mạng, tải từ Cloud về nạp vào SQLite
    if (isOnlineSimulated) {
      try {
        final response = await http
            .get(Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=4'))
            .timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final List<dynamic> jsonList = json.decode(response.body);
          for (var item in jsonList) {
            final task = TaskItem.fromJson(item);
            await dbHelper.insertTask(task);
          }
          return await dbHelper.getAllTasks();
        }
      } catch (_) {}
    }
    return [];
  }

  // 2. LOCAL-FIRST WRITE + SYNC QUEUE (Slide 10)
  Future<void> addTask(String title, String content) async {
    // Bước 1: Lưu ngay vào SQLite với isSynced = 0 để UI phản hồi tức thì
    final localTask = TaskItem(title: title, content: content, isSynced: 0);
    final insertedId = await dbHelper.insertTask(localTask);

    // Bước 2: Thử đồng bộ ngầm (Background Sync) nếu đang online
    if (isOnlineSimulated) {
      try {
        final response = await http.post(
          Uri.parse('https://jsonplaceholder.typicode.com/posts'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: json.encode(localTask.toJson()),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 201 || response.statusCode == 200) {
          // Thành công: Cập nhật isSynced = 1
          await dbHelper.updateTask(localTask.copyWith(id: insertedId, isSynced: 1));
        }
      } catch (_) {
        // Mất mạng: Giữ nguyên isSynced = 0 trong Sync Queue
      }
    }
  }

  // 3. RETRY & BACKGROUND SYNC (Slide 10: Sync Queue)
  Future<int> syncPendingTasks() async {
    if (!isOnlineSimulated) return 0;

    final allTasks = await dbHelper.getAllTasks();
    final pendingTasks = allTasks.where((t) => t.isSynced == 0).toList();
    int syncedCount = 0;

    for (var task in pendingTasks) {
      try {
        final response = await http.post(
          Uri.parse('https://jsonplaceholder.typicode.com/posts'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: json.encode(task.toJson()),
        ).timeout(const Duration(seconds: 3));

        if (response.statusCode == 201 || response.statusCode == 200) {
          await dbHelper.updateTask(task.copyWith(isSynced: 1));
          syncedCount++;
        }
      } catch (_) {
        break; // Dừng lại nếu gặp lỗi mạng
      }
    }
    return syncedCount;
  }
}

class Ex5OfflineFirstRepoScreen extends StatefulWidget {
  const Ex5OfflineFirstRepoScreen({Key? key}) : super(key: key);

  @override
  State<Ex5OfflineFirstRepoScreen> createState() => _Ex5OfflineFirstRepoScreenState();
}

class _Ex5OfflineFirstRepoScreenState extends State<Ex5OfflineFirstRepoScreen> {
  final TaskRepository _repository = TaskRepository();
  List<TaskItem> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    final data = await _repository.getTasks();
    setState(() {
      _tasks = data;
      _isLoading = false;
    });
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Task (Local-First)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tiêu đề')),
            TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Nội dung')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await _repository.addTask(titleController.text, contentController.text);
                if (mounted) Navigator.pop(ctx);
                _refresh();
              }
            },
            child: const Text('Lưu ngay'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerSyncQueue() async {
    final count = await _repository.syncPendingTasks();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã đồng bộ $count task trong Sync Queue lên Cloud!')),
      );
    }
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _tasks.where((t) => t.isSynced == 0).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 5: Offline-First'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Đồng bộ Sync Queue',
            onPressed: _triggerSyncQueue,
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            color: Colors.blue.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    '💡 Bài học từ Slide 10 & 11:\n'
                    'Local = Tốc độ (UI phản hồi ngay lập tức). Remote = Đồng bộ.\n'
                    'Khi thêm mới lúc mất mạng: Lưu vào SQLite với cờ isSynced=0. Khi có mạng lại: Tự động sync.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  SwitchListTile(
                    dense: true,
                    title: const Text('Mô phỏng Kết nối Mạng (Online/Offline)'),
                    subtitle: Text(
                      _repository.isOnlineSimulated ? 'Trạng thái: Đang Online' : 'Trạng thái: Đang Offline (Mất mạng)',
                      style: TextStyle(
                        color: _repository.isOnlineSimulated ? Colors.green : Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: _repository.isOnlineSimulated,
                    onChanged: (val) {
                      setState(() {
                        _repository.isOnlineSimulated = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tổng số: ${_tasks.length} tasks', style: const TextStyle(fontWeight: FontWeight.bold)),
                Chip(
                  avatar: Icon(
                    pendingCount > 0 ? Icons.cloud_off : Icons.cloud_done,
                    size: 18,
                    color: pendingCount > 0 ? Colors.orange : Colors.green,
                  ),
                  label: Text('Chờ sync: $pendingCount'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? const Center(child: Text('Danh sách rỗng. Bấm [+] để thêm task mới.'))
                    : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          final isSynced = task.isSynced == 1;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSynced ? Colors.green.shade100 : Colors.orange.shade100,
                                child: Icon(
                                  isSynced ? Icons.cloud_done : Icons.cloud_queue,
                                  color: isSynced ? Colors.green : Colors.orange,
                                ),
                              ),
                              title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(task.content),
                              trailing: Text(
                                isSynced ? 'Đã sync' : 'Offline queue',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSynced ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
