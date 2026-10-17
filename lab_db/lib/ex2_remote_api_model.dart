import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/task_item.dart';

/// EXERCISE 2: RESTFUL API & TYPED DART MODEL
/// References:
/// - Slide 3: Remote Database Architecture (Mobile -X-> Direct DB. Correct: Mobile -> REST API -> Backend -> DB)
/// - Slide 4: RESTful API in Flutter (http package, Typed Dart Model, Decouple networking from UI)

class ApiService {
  static const String endpoint = 'https://jsonplaceholder.typicode.com/posts';

  // GET: Fetch list of items and parse JSON to typed Dart Model
  static Future<List<TaskItem>> getTasks({int limit = 5}) async {
    final response = await http
        .get(Uri.parse('$endpoint?_limit=$limit'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((item) => TaskItem.fromJson(item)).toList();
    } else {
      throw Exception('Server returned error code: ${response.statusCode}');
    }
  }

  // POST: Send Dart Model converted to JSON to the remote API
  static Future<TaskItem> postTask(TaskItem task) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(task.toJson()),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return TaskItem.fromJson(responseData);
    } else {
      throw Exception('Failed to post task. Code: ${response.statusCode}');
    }
  }
}

class Ex2RemoteApiModelScreen extends StatefulWidget {
  const Ex2RemoteApiModelScreen({Key? key}) : super(key: key);

  @override
  State<Ex2RemoteApiModelScreen> createState() => _Ex2RemoteApiModelScreenState();
}

class _Ex2RemoteApiModelScreenState extends State<Ex2RemoteApiModelScreen> {
  List<TaskItem> _items = [];
  bool _isLoading = false;
  String _statusMessage = 'Bấm "Fetch API" để gọi dữ liệu từ REST API.';

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang gọi GET https://jsonplaceholder.typicode.com/posts...';
    });

    try {
      final results = await ApiService.getTasks(limit: 4);
      setState(() {
        _items = results;
        _isLoading = false;
        _statusMessage = 'Đã parse thành công ${results.length} Dart Model objects!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Lỗi kết nối: $e';
      });
    }
  }

  Future<void> _sendPostRequest() async {
    final newTask = TaskItem(
      title: 'Task mới từ Mobile',
      content: 'Kiểm tra gửi HTTP POST theo kiến trúc Slide 3 & 4',
    );

    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang gửi POST lên Server...';
    });

    try {
      final created = await ApiService.postTask(newTask);
      setState(() {
        _items.insert(0, created);
        _isLoading = false;
        _statusMessage = 'POST thành công! Server trả về ID: ${created.id}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Lỗi khi gửi POST: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 2: REST API & Model'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.blue.withValues(alpha: 0.1),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  '💡 Bài học từ Slide 3 & 4:\n'
                  '1. Mobile KHÔNG nối trực tiếp MySQL để bảo vệ credential & tránh sập kết nối.\n'
                  '2. Networking tách biệt hoàn toàn vào ApiService; JSON được chuyển đổi thành typed Dart Model.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _fetchData,
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Fetch GET API'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _sendPostRequest,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Test POST API'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_statusMessage, style: const TextStyle(fontStyle: FontStyle.italic)),
            const Divider(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? const Center(child: Text('Chưa có dữ liệu. Hãy bấm Fetch API.'))
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (ctx, index) {
                            final item = _items[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(child: Text('${item.id ?? "?"}')),
                                title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text(item.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
