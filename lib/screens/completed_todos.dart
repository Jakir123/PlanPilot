import 'package:flutter/material.dart';

class CompletedTodos extends StatelessWidget {
  final List<Map<String, dynamic>> todos;
  final void Function(int index) onDelete;

  const CompletedTodos({super.key, required this.todos, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return const Center(child: Text('No completed todos.'));
    }
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: ListTile(
            title: Text(todo['title'] ?? '', style: const TextStyle(decoration: TextDecoration.lineThrough)),
            subtitle: todo['description'] != null && (todo['description'] as String).isNotEmpty
                ? Text(todo['description'])
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete',
              onPressed: () => onDelete(index),
            ),
          ),
        );
      },
    );
  }
}
