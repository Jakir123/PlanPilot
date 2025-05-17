import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/custom_textfield';
import '../todo_edit_viewmodel.dart';

class EditTodoSheet extends StatefulWidget {
  final Map<String, dynamic> todo;
  final String userId;
  final bool isAnonymous;

  const EditTodoSheet({
    super.key,
    required this.todo,
    required this.userId,
    required this.isAnonymous,
  });

  @override
  State<EditTodoSheet> createState() => _EditTodoSheetState();
}

class _EditTodoSheetState extends State<EditTodoSheet> {
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
  void initState() {
    super.initState();
    _titleController.text = widget.todo['title'] ?? '';
    _descController.text = widget.todo['description'] ?? '';
    _priority = widget.todo['priority']?.toString() ?? 'Low';
    
    final category = widget.todo['category']?.toString();
    if (category != null && category.isNotEmpty) {
      if (_categories.contains(category)) {
        _selectedCategory = category;
      } else {
        _selectedCategory = 'Other';
        _categoryController.text = category;
      }
    } else {
      _selectedCategory = null;
      _categoryController.text = '';
    }
    
    if (widget.todo['dueDateTime'] != null) {
      final dueDateTime = DateTime.parse(widget.todo['dueDateTime']);
      _dueDate = DateTime(
        dueDateTime.year,
        dueDateTime.month,
        dueDateTime.day,
      );
      _dueTime = TimeOfDay(
        hour: dueDateTime.hour,
        minute: dueDateTime.minute,
      );
    }
    _reminder = widget.todo['reminder'] ?? false;
  }

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
  String? _dateTimeError;

  void _submit(BuildContext context) {
    setState(() {
      _titleError = null;
      _categoryError = null;
      _dateTimeError = null;
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
    DateTime? dueDateTime;

    if (_dueDate != null && _dueTime != null) {
      dueDateTime = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        _dueTime!.hour,
        _dueTime!.minute,
      );
    }else if (_reminder) {
      if (_dueDate == null && _dueTime != null) {
        // Only time is set, use current date with selected time
        final now = DateTime.now();
        dueDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          _dueTime!.hour,
          _dueTime!.minute,
        );
      } else if (_dueDate != null && _dueTime == null) {
        // Only date is set, use current time + 1 hour
        final now = DateTime.now();
        dueDateTime = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          now.hour + 1,
          now.minute,
        );
      }else{
        setState(() {
          _dateTimeError = 'Select date and time to set a reminder';
        });
        hasError = true;
      }
    }
    if (hasError) return;


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
    vm.updateTodo(
      docId: widget.todo['id'],
      userId: widget.userId,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      dueDateTime: dueDateTime,
      reminder: _reminder,
      priority: _priority,
      category: categoryToSave,
      isAnonymous: widget.isAnonymous,
    ).then((success) {
      if (success) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.error ?? 'Failed to update todo')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Todo'),
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
                  items: ['Low', 'Medium', 'High']
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _priority = val ?? 'Low'),
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
                              : '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}',
                        ),
                        onPressed: _pickDueTime,
                      ),
                    ),
                  ],
                ),
                if (_dateTimeError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(_dateTimeError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                SwitchListTile(
                  title: const Text('Set Reminder'),
                  value: _reminder,
                  onChanged: (val) => setState(() => _reminder = val),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() {
                    _selectedCategory = val;
                    _categoryController.text = '';
                  }),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_selectedCategory == 'Other')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: CustomTextField(
                      textEditingController: _categoryController,
                      labelText: 'Enter custom category',
                      inputAction: TextInputAction.done,
                      onValueChange: (_) => setState(() {}),
                      isPassword: false,
                    ),
                  ),
                if (_categoryError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(_categoryError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _submit(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
