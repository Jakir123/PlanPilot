import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/todo_list_item.dart';
import '../todo_edit_viewmodel.dart';
import 'authentication/auth_viewmodel.dart';

class PendingTodos extends StatelessWidget {
  const PendingTodos({super.key});

  int _priorityValue(String? priority) {
    switch ((priority ?? '').toLowerCase()) {
      case 'high':
        return 0;
      case 'medium':
        return 1;
      case 'low':
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TodoEditViewModel, AuthViewModel>(
      builder: (context, todoVm, authVm, _) {
        final user = authVm.user;
        if (user == null) {
          return const Center(child: Text('Not signed in.'));
        }
        final isAnonymous = user.isAnonymous;
        return StreamBuilder(
          stream: todoVm.firebaseService.pendingTodosStream(user.uid, isAnonymous: isAnonymous),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: \${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No pending todos.'));
            }
            final docs = snapshot.data!.docs;
            final todos = docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList();
            todos.sort((a, b) => _priorityValue(a['priority']).compareTo(_priorityValue(b['priority'])));
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return TodoListItem(
                  todo: todo,
                  userId: user.uid,
                  isAnonymous: isAnonymous,
                );
              },
            );
          },
        );
      },
    );
  }
}

