import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Todo> _todos = [
    Todo(id: 1, title: 'Buy milk'),
    Todo(id: 2, title: 'Finish Lab 3'),
    Todo(id: 3, title: 'Review lecture slides'),
  ];

  int _nextId = 4;
  final TextEditingController _textController = TextEditingController();

  // Bug 3
  // String? _filter;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Bug 1
  // int _countCompletedTodos() {
  //   int done = 0;
  //   for (var i = 0; i <= _todos.length; i++) {
  //     done += _todos[i].done ? 1 : 0;
  //   }
  //   return done;
  // }

  void _addTodo(String title) {
    if (title.trim().isEmpty) return;

    // Bug 3:
    // final visible = _todos.where((t) => t.title.contains(_filter!)).toList();

    setState(() {
      _todos.add(Todo(
        id: _nextId++,
        title: title.trim(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: _todos.isEmpty
          ? const Center(
              child: Text('Nothing to do yet.'),
            )
          : ListView.builder(
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
                      // Bug 2
                      // todo.done = val ?? false;

                      setState(() {
                        todo.done = val ?? false;
                      });
                    },
                  ),
                );
              },
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
            decoration: todo.done ? TextDecoration.lineThrough : null,
          ),
        ),
        value: todo.done,
        onChanged: onChanged,
      ),
    );
  }
}