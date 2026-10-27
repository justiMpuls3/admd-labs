class Todo {
  final int id;
  final String title;
  bool done;

  Todo({
    required this.id,
    required this.title,
    this.done = false,
  });
}
