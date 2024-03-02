// ignore: file_names
import 'package:flutter/material.dart';
import 'package:todo_app/todo.dart';
import 'package:todo_app/todoDatabase.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late TodoDatabase _database;
  bool _isLoading = true;
  List<TodoItem> _todos = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = TodoDatabase();
    await _database.init();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    List<TodoItem> todos = await _database.getTodos();
    setState(() {
      _isLoading = false;
      _todos = todos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          'Todoey',
          style: TextStyle(fontSize: 32),
        )),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _todos.isEmpty
              ? const Center(
                  child: Text(
                    'No todos yet!',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                )
              : ListView.separated(
                  itemCount: _todos.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemBuilder: (context, index) {
                    return _buildTodoItem(index);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        tooltip: 'Add Todo',
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoItem(int index) {
    final todo = _todos[index];
    return Dismissible(
      key: Key(todo.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm"),
              content: const Text("Are you sure you want to delete this todo?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    "DELETE",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    "CANCEL",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteTodo(todo);
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          leading: IconButton(
            icon: Icon(
              todo.isCompleted ? Icons.check : Icons.close,
              color: todo.isCompleted ? Colors.green : Colors.red,
            ),
            onPressed: () {
              _toggleTodoCompletion(todo);
            },
          ),
          title: Text(
            todo.text,
            style: TextStyle(
              fontSize: 18,
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: todo.description.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    todo.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editTodo(todo),
              ),
              const Icon(Icons.drag_handle),
            ],
          ),
        ),
      ),
    );
  }

  void _addTodo() async {
    final newTodo = await showDialog<TodoItem>(
      context: context,
      builder: (context) {
        TodoItem todo = TodoItem(text: '', description: '');
        return AlertDialog(
          title: const Text('Add Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  todo.text = value;
                },
                decoration: InputDecoration(
                  hintText: 'Title',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.white)),
                ),
              ),
              TextField(
                onChanged: (value) {
                  todo.description = value;
                },
                decoration: InputDecoration(
                  hintText: 'Description',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.white)),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (todo.text.trim().isNotEmpty) {
                  await _database.insertTodo(todo);
                  _loadTodos();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Text cannot be empty!'),
                    ),
                  );
                }
              },
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (newTodo != null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todo Added Successfully!')));
    }
  }

  void _editTodo(TodoItem todo) async {
    final editedTodo = await showDialog<TodoItem>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  todo.text = value;
                },
                controller: TextEditingController(text: todo.text),
                decoration: InputDecoration(
                  hintText: 'Title',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.white)),
                ),
              ),
              TextField(
                onChanged: (value) {
                  todo.description = value;
                },
                controller: TextEditingController(text: todo.description),
                decoration: InputDecoration(
                  hintText: 'Description',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.white)),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (todo.text.trim().isNotEmpty) {
                  await _database.updateTodo(todo);
                  _loadTodos();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Text cannot be empty!'),
                    ),
                  );
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (editedTodo != null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todo Edited Successfully!')));
    }
  }

  void _deleteTodo(TodoItem todo) async {
    await _database.deleteTodo(todo);
    _loadTodos();
  }

  void _toggleTodoCompletion(TodoItem todo) async {
    todo.isCompleted = !todo.isCompleted;
    await _database.updateTodoCompletion(todo);
    _loadTodos();
  }
}
