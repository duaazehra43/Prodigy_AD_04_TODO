class TodoItem {
  int? id;
  String text;
  String description;
  bool isCompleted;

  TodoItem({
    this.id,
    required this.text,
    required this.description,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}
