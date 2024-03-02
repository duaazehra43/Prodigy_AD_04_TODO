import 'package:todo_app/todo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TodoDatabase {
  late Database _database;

  Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'todo_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE todos(id INTEGER PRIMARY KEY, text TEXT, description TEXT, isCompleted INTEGER)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertTodo(TodoItem todo) async {
    await _database.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTodo(TodoItem todo) async {
    await _database.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> updateTodoCompletion(TodoItem todo) async {
    await _database.update(
      'todos',
      {'isCompleted': todo.isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTodo(TodoItem todo) async {
    await _database.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<List<TodoItem>> getTodos() async {
    final List<Map<String, dynamic>> maps = await _database.query('todos');
    return List.generate(maps.length, (i) {
      return TodoItem(
        id: maps[i]['id'],
        text: maps[i]['text'],
        description: maps[i]['description'],
        isCompleted: maps[i]['isCompleted'] == 1,
      );
    });
  }
}
