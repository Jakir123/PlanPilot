import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../components/priority_category_tag.dart';
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
              return Center(child: Text('Error: \\${snapshot.error}'));
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
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Slidable(
                      key: ValueKey(todo['id']),
                      startActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            onPressed: (_) async {
                              await todoVm.firebaseService.updateTodoCompleteStatus(
                                userId: user.uid,
                                docId: todo['id'],
                                isCompleted: true,
                                isAnonymous: isAnonymous,
                              );
                            },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.check_circle,
                            label: 'Complete',
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.5,
                        children: [
                          SlidableAction(
                            onPressed: (_) {/* TODO: implement edit */},
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                            spacing: 4,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          SlidableAction(
                            onPressed: (_) async {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                builder: (context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        const Text(
                                          'Delete Todo',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Are you sure you want to delete this todo?\n"${todo['title'] ?? ''}"',
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: const Text('Cancel'),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                  await todoVm.firebaseService.deleteTodo(
                                                    userId: user.uid,
                                                    docId: todo['id'],
                                                    isAnonymous: isAnonymous,
                                                  );
                                                },
                                                child: const Text('Yes, Delete'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            spacing: 4,
                            label: 'Delete',
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    PriorityTag(todo['priority'] ?? 'low'),
                                    if ((todo['category'] ?? '').toString().isNotEmpty)
                                      CategoryTag(todo['category']),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
                                  child: Text(
                                    todo['title'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                if ((todo['description'] ?? '').toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12, right: 12, top: 4),
                                    child: Text(
                                      todo['description'],
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14,color: Colors.grey),
                                    ),
                                  ),
                                if (todo['dueDateTime'] != null && (todo['dueDateTime'] as String).isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
                                    child: Row(
                                      children: [
                                        Text(
                                          DateFormat('EEE d MMM yyyy, hh:mm a').format(DateTime.parse(todo['dueDateTime'])),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14,color: Colors.grey[600]),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.notifications,
                                          color: (todo['reminder'] == true)
                                              ? Colors.orange
                                              : Colors.grey,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
