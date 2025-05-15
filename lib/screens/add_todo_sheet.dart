import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../todo_edit_viewmodel.dart';
import '../components/custom_textfield';

class AddTodoSheet extends StatefulWidget {
  const AddTodoSheet({super.key});

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _reminder = false;
  String _priority = 'Low';
  List<String> _categories = ['Work', 'Personal', 'Shopping', 'Other'];
  String? _selectedCategory;
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _pickDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  String? _titleError;
  String? _categoryError;

  void _submit(BuildContext context) {
    setState(() {
      _titleError = null;
      _categoryError = null;
    });
    bool hasError = false;
    if (_titleController.text.trim().isEmpty) {
      setState(() {
        _titleError = 'Title is required';
      });
      hasError = true;
    }
    if (_selectedCategory == 'Other' && _categoryController.text.trim().isEmpty) {
      setState(() {
        _categoryError = 'Enter a category';
      });
      hasError = true;
    }
    if (hasError) return;

    final dueDateTime =
        (_dueDate != null && _dueTime != null)
            ? DateTime(
              _dueDate!.year,
              _dueDate!.month,
              _dueDate!.day,
              _dueTime!.hour,
              _dueTime!.minute,
            )
            : null;
    String? categoryToSave;
    if (_selectedCategory == 'Other') {
      final customCat = _categoryController.text.trim();
      if (customCat.isNotEmpty) {
        categoryToSave = customCat;
      }
    } else {
      categoryToSave = _selectedCategory;
    }
    final vm = Provider.of<TodoEditViewModel>(context, listen: false);
    vm.addTodo(
          title: _titleController.text.trim(),
          description:
              _descController.text.trim().isEmpty
                  ? null
                  : _descController.text.trim(),
          dueDateTime: dueDateTime,
          reminder: _reminder,
          priority: _priority,
          category: categoryToSave,
        )
        .then((success) {
          if (success) {
            Navigator.of(context).pop();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoEditViewModel(),
      child: Consumer<TodoEditViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Add New Todo'),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        textEditingController: _titleController,
                        labelText: 'Title',
                        inputAction: TextInputAction.next,
                        onValueChange: (_) => setState(() {}),
                        isPassword: false,
                      ),
                      if (_titleError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(_titleError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        textEditingController: _descController,
                        labelText: 'Description (optional)',
                        inputAction: TextInputAction.next,
                        maxLines: 2,
                        isPassword: false,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _priority,
                        items:
                            ['Low', 'Medium', 'High']
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => _priority = val ?? 'Low'),
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _dueDate == null
                                    ? 'Pick Due Date'
                                    : '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}',
                              ),
                              onPressed: _pickDueDate,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.access_time),
                              label: Text(
                                _dueTime == null
                                    ? 'Pick Time'
                                    : _dueTime!.format(context),
                              ),
                              onPressed: _pickDueTime,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _reminder,
                            onChanged:
                                (val) =>
                                    setState(() => _reminder = val ?? false),
                          ),
                          const Text('Set reminder for this task'),
                        ],
                      ),
                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items: _categories
                              .map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCategory = val;
                              if (val != 'Other') {
                                _categoryController.clear();
                              }
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Category (optional)',
                            border: OutlineInputBorder(),
                          ),
                          isExpanded: true,
                          hint: const Text('Select or add category'),
                        ),
                      ),
                      if (_selectedCategory == 'Other') ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: CustomTextField(
                            textEditingController: _categoryController,
                            labelText: 'Add new category',
                            inputAction: TextInputAction.done,
                            isPassword: false,
                          ),
                        ),
                        if (_categoryError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(_categoryError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              vm.isLoading ? null : () => _submit(context),
                          child:
                              vm.isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Add Todo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
