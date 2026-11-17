import 'package:flutter/material.dart';

import '../api/todo_api.dart';
import '../models/todo.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Todo> _todos = [];
  final List<String> _log = [];
  final TextEditingController _textController = TextEditingController();

  int _nextId = 201;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final todos = await fetchTodos(path: '/nope',
        onLog: (message) {
          if (!mounted) return;
          setState(() {
            _log.add(message);
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _todos.addAll(todos);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load todos';
        _loading = false;
      });
    }
  }

  void _addTodo(String title) {
    if (title.trim().isEmpty) return;

    setState(() {
      _todos.add(Todo(
        userId: 1,
        id: _nextId++,
        title: title.trim(),
        completed: false,
      ));
    });
    _textController.clear();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Todo'),
          content: TextField(
            controller: _textController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter todo title'),
            onSubmitted: (value) {
              _addTodo(value);
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _textController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _addTodo(_textController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = _error;
    if (error != null) {
      return Center(child: Text(error));
    }
    if (_todos.isEmpty) {
      return const Center(child: Text('Nothing to do yet.'));
    }
    return ListView.builder(
      itemCount: _todos.length,
      itemBuilder: (context, index) {
        final todo = _todos[index];
        return Dismissible(
          key: ValueKey(todo.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            final removedTodo = todo;
            final removedIndex = index;

            setState(() {
              _todos.removeWhere((t) => t.id == todo.id);
            });

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Removed "${removedTodo.title}"'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    setState(() {
                      _todos.insert(removedIndex, removedTodo);
                    });
                  },
                ),
              ),
            );
          },
          child: TodoTile(
            todo: todo,
            onChanged: (val) {
              setState(() {
                _todos[index] = Todo(
                  userId: todo.userId,
                  id: todo.id,
                  title: todo.title,
                  completed: val ?? false,
                );
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Column(
        children: [
          if (_log.isNotEmpty)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: _log.map((line) => Text(line)).toList(),
                ),
              ),
            ),
          Expanded(child: _buildList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodoTile extends StatelessWidget {
  final Todo todo;
  final ValueChanged<bool?> onChanged;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: CheckboxListTile(
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        value: todo.completed,
        onChanged: onChanged,
      ),
    );
  }
}