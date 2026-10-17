import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'models/task_item.dart';

/// EXERCISE 4: LOCAL RELATIONAL DATABASE WITH SQLITE (SQFLITE)
/// References:
/// - Slide 8: SQLite (sqflite) - Relational DB, ACID transactions, CRUD, filtering.
/// - Slide 9: Storage Selection Table (SQLite for structured relational data & offline queries).

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks_local.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            isSynced INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // CREATE
  Future<int> insertTask(TaskItem task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }

  // READ ALL
  Future<List<TaskItem>> getAllTasks() async {
    final db = await instance.database;
    final results = await db.query('tasks', orderBy: 'id DESC');
    return results.map((map) => TaskItem.fromMap(map)).toList();
  }

  // UPDATE
  Future<int> updateTask(TaskItem task) async {
    final db = await instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // DELETE
  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class Ex4SqliteCrudScreen extends StatefulWidget {
  const Ex4SqliteCrudScreen({Key? key}) : super(key: key);

  @override
  State<Ex4SqliteCrudScreen> createState() => _Ex4SqliteCrudScreenState();
}

class _Ex4SqliteCrudScreenState extends State<Ex4SqliteCrudScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<TaskItem> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshTaskList();
  }

  Future<void> _refreshTaskList() async {
    setState(() => _isLoading = true);
    final data = await _dbHelper.getAllTasks();
    setState(() {
      _tasks = data;
      _isLoading = false;
    });
  }

  void _showTaskDialog({TaskItem? taskToEdit}) {
    final titleController = TextEditingController(text: taskToEdit?.title ?? '');
    final contentController = TextEditingController(text: taskToEdit?.content ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(taskToEdit == null ? 'Thêm mới Task (SQLite)' : 'Chỉnh sửa Task'),
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
              final title = titleController.text.trim();
              final content = contentController.text.trim();
              if (title.isNotEmpty) {
                if (taskToEdit == null) {
                  // Insert
                  await _dbHelper.insertTask(TaskItem(title: title, content: content, isSynced: 1));
                } else {
                  // Update
                  await _dbHelper.updateTask(taskToEdit.copyWith(title: title, content: content));
                }
                if (mounted) Navigator.pop(ctx);
                _refreshTaskList();
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    _refreshTaskList();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa task khỏi SQLite!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 4: SQLite CRUD'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshTaskList),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            color: Colors.blue.withValues(alpha: 0.08),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                '💡 Bài học từ Slide 8 & 9:\n'
                'SQLite hỗ trợ đầy đủ ACID (Atomicity, Consistency, Isolation, Durability). '
                'Dữ liệu tồn tại vĩnh viễn trên máy ngay cả khi tắt nguồn, không phụ thuộc vào internet.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? const Center(child: Text('Chưa có task nào trong SQLite. Bấm [+] để thêm.'))
                    : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(child: Text('${task.id}')),
                              title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(task.content),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showTaskDialog(taskToEdit: task),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => _deleteTask(task.id!),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
