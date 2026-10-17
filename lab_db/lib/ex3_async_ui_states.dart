import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/task_item.dart';

/// EXERCISE 3: FUTUREBUILDER & ASYNC UI (3 UI STATES)
/// References:
/// - Slide 5: FutureBuilder & Async UI
///   "Một Future, ba trạng thái giao diện: LOADING -> ERROR (Thử lại) -> SUCCESS"
///   "Không block UI khi chờ API"

class Ex3AsyncUiStatesScreen extends StatefulWidget {
  const Ex3AsyncUiStatesScreen({Key? key}) : super(key: key);

  @override
  State<Ex3AsyncUiStatesScreen> createState() => _Ex3AsyncUiStatesScreenState();
}

class _Ex3AsyncUiStatesScreenState extends State<Ex3AsyncUiStatesScreen> {
  late Future<List<TaskItem>> _tasksFuture;
  bool _simulateError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _tasksFuture = _fetchTasksWithSimulation();
    });
  }

  Future<List<TaskItem>> _fetchTasksWithSimulation() async {
    // Artificial delay to observe LOADING state
    await Future.delayed(const Duration(milliseconds: 1200));

    if (_simulateError) {
      throw Exception('Mô phỏng lỗi mạng (Network Timeout / 500 Server Error)!');
    }

    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=6'))
        .timeout(const Duration(seconds: 4));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((jsonItem) => TaskItem.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 3: FutureBuilder 3 States'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              color: Colors.blue.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text(
                      '💡 Bài học từ Slide 5:\n'
                      'FutureBuilder xử lý bất đồng bộ không làm đứng màn hình (non-blocking). '
                      'Luôn chuẩn bị đủ 3 trạng thái: Loading, Error (kèm nút Thử lại) và Success.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      dense: true,
                      title: const Text('Mô phỏng xảy ra lỗi (Simulate Error)'),
                      subtitle: Text(_simulateError ? 'Chế độ: Gây lỗi' : 'Chế độ: Bình thường'),
                      value: _simulateError,
                      onChanged: (val) {
                        setState(() {
                          _simulateError = val;
                        });
                        _loadData();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TaskItem>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                // 1. LOADING STATE (Slide 5: Spinner)
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Đang tải dữ liệu từ API...', style: TextStyle(color: Colors.blueGrey)),
                      ],
                    ),
                  );
                }

                // 2. ERROR STATE (Slide 5: Error Icon + Retry Button)
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                          const SizedBox(height: 12),
                          const Text(
                            'Đã xảy ra lỗi!',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại (Retry)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // 3. SUCCESS STATE (Slide 5: Render Data)
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(child: Text('Danh sách trống.'));
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          child: Text('${item.id ?? index + 1}'),
                        ),
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(item.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
