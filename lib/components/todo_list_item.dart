import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../todo_edit_viewmodel.dart';
import '../components/priority_category_tag.dart';
import '../screens/edit_todo_sheet.dart';

class TodoListItem extends StatelessWidget {
  final Map<String, dynamic> todo;
  final String userId;
  final bool isAnonymous;

  const TodoListItem({
    super.key,
    required this.todo,
    required this.userId,
    required this.isAnonymous,
  });

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    await showModalBottomSheet(
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
              Lottie.asset('assets/animations/delete.json', height: 120),
              const SizedBox(height: 4),
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
                        final vm = context.read<TodoEditViewModel>();
                        final success = await vm.deleteTodo(
                          context: context,
                          userId: userId,
                          docId: todo['id'],
                          isNotificationEnabled: todo['reminder'],
                          isAnonymous: isAnonymous,
                        );
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(vm.error ?? 'Failed to delete todo'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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
  }

  Future<void> _showCompletionCelebration(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
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
              Lottie.asset('assets/animations/congratulations.json', height: 120),
              const SizedBox(height: 4),
              const Text(
                'Great Job!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'You completed: "${todo['title'] ?? ''}"',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16,color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Slidable(
        key: ValueKey(todo['id']),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.30,
          children: [
            SlidableAction(
              onPressed: (_) async {
                _showCompletionCelebration(context);
                context.read<TodoEditViewModel>().firebaseService.updateTodoCompleteStatus(
                  userId: userId,
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
              onPressed: (_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditTodoSheet(
                    todo: todo,
                    userId: userId,
                    isAnonymous: isAnonymous,
                  )),
                );
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              spacing: 4,
              borderRadius: BorderRadius.circular(8),
            ),
            SlidableAction(
              onPressed: (_) => _showDeleteConfirmation(context),
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    if (todo['dueDateTime'] != null && (todo['dueDateTime'] as String).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
                        child: Row(
                          children: [
                            Text(
                              DateFormat('EEE d MMM yyyy, hh:mm a').format(DateTime.parse(todo['dueDateTime'])),
                              style: const TextStyle(fontSize: 12),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
