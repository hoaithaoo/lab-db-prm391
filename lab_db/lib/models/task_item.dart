class TaskItem {
  final int? id;
  final String title;
  final String content;
  final int isSynced; // 1 = Synced with Remote Cloud, 0 = Pending in Local Sync Queue

  TaskItem({
    this.id,
    required this.title,
    required this.content,
    this.isSynced = 1,
  });

  // Convert from SQLite Map (Slide 8, 10)
  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      isSynced: map['isSynced'] as int? ?? 1,
    );
  }

  // Convert to SQLite Map (Slide 8, 10)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'content': content,
      'isSynced': isSynced,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Convert from REST API JSON (Slide 4)
  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      content: (json['body'] ?? json['content'] ?? '') as String,
      isSynced: 1,
    );
  }

  // Convert to REST API JSON (Slide 4)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': content,
      'userId': 1,
    };
  }

  TaskItem copyWith({
    int? id,
    String? title,
    String? content,
    int? isSynced,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
