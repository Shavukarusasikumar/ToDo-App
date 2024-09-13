// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/model/toDoModel.dart';
import 'package:todo/viewModel/toDoViewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF547D58),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.assignment_outlined)),
            Tab(text: 'Completed', icon: Icon(Icons.assignment_turned_in)),
          ],
          indicatorColor: const Color(0xFF1F2F12),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFFA8C98E),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodoList(context, false, isTablet),
          _buildTodoList(context, true, isTablet),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF547D58),
      ),
    );
  }

  Widget _buildTodoList(BuildContext context, bool isCompleted, bool isTablet) {
    return Consumer<todoViewModel>(
      builder: (context, viewModel, child) {
        final todos = isCompleted ? viewModel.completedToDos : viewModel.incompleteToDos;
        return todos.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCompleted ? Icons.assignment_turned_in : Icons.assignment_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isCompleted ? 'No completed tasks' : 'No active tasks',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) => buildTodoTile(context, todos[index], viewModel, isTablet),
              );
      },
    );
  }
Widget buildTodoTile(BuildContext context, toDo todo, todoViewModel viewModel, bool isTablet) {
  final screenSize = MediaQuery.of(context).size;
  final cardWidth = isTablet ? screenSize.width * 0.7 : screenSize.width * 0.9;

  return Center(
    child: Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  todo.iscompleted ? Colors.green.withOpacity(0.1) : const Color(0xFF547D58).withOpacity(0.1),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () => viewModel.toggleCompletion(todo),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: todo.iscompleted ? Colors.green.withOpacity(0.1) : const Color(0xFF547D58).withOpacity(0.1),
                      ),
                      child: Icon(
                        todo.iscompleted ? Icons.check_circle : Icons.circle_outlined,
                        color: todo.iscompleted ? Colors.green : const Color(0xFF547D58),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Todo content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            decoration: todo.iscompleted ? TextDecoration.lineThrough : null,
                            color: todo.iscompleted ? Colors.grey[600] : Colors.black87,
                          ),
                        ),
                        if (todo.description != null && todo.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              todo.description!,
                              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            ),
                          ),
                        if (todo.dueDate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.event, size: 18, color: Color(0xFF547D58)),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDateTime(todo.dueDate!, todo.dueTime),
                                  style: const TextStyle(fontSize: 14, color: Color(0xFF547D58), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Column(
                    children: [
                      if (!todo.iscompleted)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF547D58)),
                          onPressed: () => _showEditTodoDialog(context, todo, viewModel),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => viewModel.toDodeletion(viewModel.todos.indexOf(todo)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  String _formatDateTime(DateTime date, TimeOfDay? time) {
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    final formattedTime = time != null ? ' ${time.format(context)}' : '';
    return '$formattedDate$formattedTime';
  }

  void _showAddTodoDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task', style: TextStyle(color: Color(0xfff547d58), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  cursorColor:const Color(0xfff547d58),
                  controller: titleController,
                  decoration: InputDecoration(
                    
                     hoverColor: const Color(0xfff547d58),
                    labelText: 'Title',
                     labelStyle: const TextStyle(color: Color(0xfff547d58)),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xfff547d58),)
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xfff547d58),width: 2)
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.title, color: Color(0xfff547d58)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  cursorColor:const Color(0xfff547d58),
                  controller: descriptionController,
                  decoration: InputDecoration(
                     hoverColor: const Color(0xfff547d58),
                    labelStyle: const TextStyle(color: Color(0xfff547d58)),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xfff547d58),)
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xfff547d58),width: 2)
                    ),
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.description, color: Color(0xfff547d58)),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xfff547d58),
                                    onPrimary: Colors.white,
                                    onSurface: Color(0xfff547d58),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            setState(() => selectedDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today,color: Colors.white,),
                        label: Text(selectedDate != null ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}' : 'Due Date',style: const TextStyle(color: Colors.white,),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfff547d58),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xfff547d58),
                                    onPrimary: Colors.white,
                                    onSurface: Color(0xfff547d58),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) {
                            setState(() => selectedTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time,color: Colors.white),
                        label: Text(selectedTime != null ? selectedTime!.format(context) : 'Due Time',style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfff547d58),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xfff547d58))),
          ),
        
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate() && selectedDate != null && selectedTime != null) {
                Provider.of<todoViewModel>(context, listen: false).addToDo(
                  titleController.text,
                  selectedDate!,
                  selectedTime!,
                  descriptionController.text,
                );
                Navigator.pop(context);
              } else if (selectedDate == null || selectedTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select both date and time')),
                );
              }
            },
            child: const Text('Add Task',style: TextStyle(color: Colors.white),),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfff547d58),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTodoDialog(BuildContext context, toDo todo, todoViewModel viewModel) {
  final titleController = TextEditingController(text: todo.title);
  final descriptionController = TextEditingController(text: todo.description);
  DateTime? selectedDate = todo.dueDate;
  TimeOfDay? selectedTime = todo.dueTime;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Task', style: TextStyle(color: Color(0xfff547d58), fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                cursorColor:const Color(0xfff547d58),
                controller: titleController,
                decoration: InputDecoration(
                   hoverColor: const Color(0xfff547d58),
                  labelStyle: const TextStyle(color: Color(0xfff547d58)),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xfff547d58),)
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xfff547d58),width: 2)
                    ),
                  labelText: 'Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.title, color: Color(0xfff547d58)),
                ),
                validator: (value) => value!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                cursorColor:const Color(0xfff547d58),
                decoration: InputDecoration(
                  
                  labelStyle: const TextStyle(color: Color(0xfff547d58)),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xfff547d58),)
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xfff547d58),width: 2)
                    ),
                    hoverColor: const Color(0xfff547d58),
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.description, color: Color(0xfff547d58)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                             builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xfff547d58),
                                    onPrimary: Colors.white,
                                    onSurface: Color(0xfff547d58),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                      icon: const Icon(Icons.calendar_today,color: Colors.white),
                      label: Text(selectedDate != null ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}' : 'Due Date',style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xfff547d58),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                           builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xfff547d58),
                                    onPrimary: Colors.white,
                                    onSurface: Color(0xfff547d58),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                        );
                        if (time != null) {
                          setState(() => selectedTime = time);
                        }
                      },
                      icon: const Icon(Icons.access_time,color: Colors.white,),
                      label: Text(selectedTime != null ? selectedTime!.format(context) : 'Due Time',style: const TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xfff547d58),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Color(0xfff547d58))),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && selectedDate != null && selectedTime != null) {
              viewModel.editTodo(
                viewModel.todos.indexOf(todo),
                titleController.text,
                selectedDate!,
                selectedTime!,
                descriptionController.text,
              );
              Navigator.pop(context);
            } else if (selectedDate == null || selectedTime == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select both date and time')),
              );
            }
          },
          child: const Text('Update Task',style: TextStyle(color: Colors.white),),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xfff547d58),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    ),
  );
}

}