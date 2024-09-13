import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/model/toDoModel.dart';
import 'package:todo/viewModel/toDoViewmodel.dart';

// Widget to build the list of todos
Widget buildTodoList(BuildContext context, bool isCompleted, bool isTablet) {
  return Consumer<todoViewModel>(
    builder: (context, viewModel, child) {
      final todos =
          isCompleted ? viewModel.completedToDos : viewModel.incompleteToDos;
      return todos.isEmpty
          ? _buildEmptyState(isCompleted)
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) =>
                  buildTodoTile(context, todos[index], viewModel, isTablet),
            );
    },
  );
}

// Widget to show when there are no todos
Widget _buildEmptyState(bool isCompleted) {
  return Center(
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
  );
}

// Widget to build individual todo tile
Widget buildTodoTile(
    BuildContext context, toDo todo, todoViewModel viewModel, bool isTablet) {
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
                  todo.iscompleted
                      ? Colors.green.withOpacity(0.1)
                      : const Color(0xFF547D58).withOpacity(0.1),
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
                  _buildCheckbox(todo, viewModel),
                  const SizedBox(width: 16),
                  _buildTodoContent(context, todo),
                  _buildActionButtons(context, todo, viewModel),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// Widget for the todo checkbox
Widget _buildCheckbox(toDo todo, todoViewModel viewModel) {
  return GestureDetector(
    onTap: () => viewModel.toggleCompletion(todo),
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: todo.iscompleted
            ? Colors.green.withOpacity(0.1)
            : const Color(0xFF547D58).withOpacity(0.1),
      ),
      child: Icon(
        todo.iscompleted ? Icons.check_circle : Icons.circle_outlined,
        color: todo.iscompleted ? Colors.green : const Color(0xFF547D58),
        size: 28,
      ),
    ),
  );
}

Widget _buildTodoContent(BuildContext context, toDo todo) {
  return Expanded(
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
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            todo.description,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              const Icon(Icons.event, size: 18, color: Color(0xFF547D58)),
              const SizedBox(width: 4),
              Text(
                _formatDateTime(context, todo.dueDate, todo.dueTime),
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF547D58),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Widget for the action buttons (edit and delete)
Widget _buildActionButtons(
    BuildContext context, toDo todo, todoViewModel viewModel) {
  final formKey = GlobalKey<FormState>(); // Declare the formKey here

  return Column(
    children: [
      if (!todo.iscompleted)
        IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFF547D58)),
          onPressed: () =>
              showEditTodoDialog(context, todo, viewModel, formKey),
        ),
      IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: () => viewModel.toDodeletion(viewModel.todos.indexOf(todo)),
      ),
    ],
  );
}

// Helper function to format date and time
String _formatDateTime(BuildContext context, DateTime date, TimeOfDay? time) {
  final formattedDate = '${date.day}/${date.month}/${date.year}';
  final formattedTime = time != null ? ' ${time.format(context)}' : '';
  return '$formattedDate$formattedTime';
}



// Dialog to edit an existing todo
void showEditTodoDialog(BuildContext context, toDo todo,
    todoViewModel viewModel, GlobalKey<FormState> formKey) {
  final titleController = TextEditingController(text: todo.title);
  final descriptionController = TextEditingController(text: todo.description);
  DateTime? selectedDate = todo.dueDate;
  TimeOfDay? selectedTime = todo.dueTime;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Task',
          style: TextStyle(
              color: Color(0xfff547d58), fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(titleController, 'Title', Icons.title, true),
              const SizedBox(height: 16),
              _buildTextField(descriptionController, 'Description (Optional)',
                  Icons.description, false,
                  maxLines: 3),
              const SizedBox(height: 16),
              _buildDateTimePickers(context, selectedDate, selectedTime,
                  (newDate) {
                selectedDate = newDate; 
              }, (newTime) {
                selectedTime = newTime; 
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              const Text('Cancel', style: TextStyle(color: Color(0xfff547d58))),
        ),
        ElevatedButton(
          onPressed: () => _handleEditTask(
              context,
              formKey,
              viewModel,
              todo,
              titleController,
              descriptionController,
              selectedDate,
              selectedTime),
          child:
              const Text('Update Task', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xfff547d58),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    ),
  );
}

// Helper function to build text fields
Widget _buildTextField(TextEditingController controller, String label,
    IconData icon, bool isRequired,
    {int maxLines = 1}) {
  return TextFormField(
    cursorColor: const Color(0xfff547d58),
    controller: controller,
    decoration: InputDecoration(
      hoverColor: const Color(0xfff547d58),
      labelStyle: const TextStyle(color: Color(0xfff547d58)),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xfff547d58)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xfff547d58), width: 2),
      ),
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      prefixIcon: Icon(icon, color: Color(0xfff547d58)),
    ),
    maxLines: maxLines,
    validator: isRequired
        ? (value) => value!.isEmpty ? '$label is required' : null
        : null,
  );
}



// Helper function to handle adding a new task
void _handleAddTask(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController titleController,
    TextEditingController descriptionController,
    DateTime? selectedDate,
    TimeOfDay? selectedTime) {
  if (formKey.currentState!.validate() &&
      selectedDate != null &&
      selectedTime != null) {
    Provider.of<todoViewModel>(context, listen: false).addToDo(
      titleController.text,
      selectedDate,
      selectedTime,
      descriptionController.text,
    );
    Navigator.pop(context);
  } else if (selectedDate == null || selectedTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select both date and time')),
    );
  }
}

// Helper function to handle editing an existing task
void _handleEditTask(
    BuildContext context,
    GlobalKey<FormState> formKey,
    todoViewModel viewModel,
    toDo todo,
    TextEditingController titleController,
    TextEditingController descriptionController,
    DateTime? selectedDate,
    TimeOfDay? selectedTime) {
  if (formKey.currentState!.validate() &&
      selectedDate != null &&
      selectedTime != null) {
    viewModel.editTodo(
      viewModel.todos.indexOf(todo),
      titleController.text,
      selectedDate,
      selectedTime,
      descriptionController.text,
    );
    Navigator.pop(context);
  } else if (selectedDate == null || selectedTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select both date and time')),
    );
  }
}



// Dialog to add a new todo
void showAddTodoDialog(BuildContext context, GlobalKey<FormState> formKey) {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text(
          'Add New Task',
          style:
              TextStyle(color: Color(0xfff547d58), fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(titleController, 'Title', Icons.title, true),
                const SizedBox(height: 16),
                _buildTextField(descriptionController, 'Description (Optional)',
                    Icons.description, false,
                    maxLines: 3),
                const SizedBox(height: 16),
                _buildDateTimePickers(context, selectedDate, selectedTime,
                    (newDate) {
                  selectedDate = newDate; 
                }, (newTime) {
                  selectedTime = newTime;
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xfff547d58))),
          ),
          ElevatedButton(
            onPressed: () => _handleAddTask(context, formKey, titleController,
                descriptionController, selectedDate, selectedTime),
            child:
                const Text('Add Task', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfff547d58),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    ),
  );
}

// Helper function to build date and time pickers
Widget _buildDateTimePickers(
  BuildContext context,
  DateTime? selectedDate,
  TimeOfDay? selectedTime,
  Function(DateTime) onDateSelected, 
  Function(TimeOfDay) onTimeSelected, 
) {
  return Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () async {
            final DateTime? pickedDate =
                await _selectDate(context, selectedDate);
            if (pickedDate != null) {
              onDateSelected(
                  pickedDate);
            }
          },
          icon: const Icon(Icons.calendar_today, color: Colors.white),
          label: Text(
            selectedDate != null
                ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                : 'Due Date',
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xfff547d58),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () async {
            final TimeOfDay? pickedTime =
                await _selectTime(context, selectedTime);
            if (pickedTime != null) {
              onTimeSelected(
                  pickedTime); 
            }
          },
          icon: const Icon(Icons.access_time, color: Colors.white),
          label: Text(
            selectedTime != null ? selectedTime.format(context) : 'Due Time',
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xfff547d58),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    ],
  );
}

// Helper function to select a date
Future<DateTime?> _selectDate(
    BuildContext context, DateTime? selectedDate) async {
  final DateTime? picked = await showDatePicker(
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
  return picked;
}

// Helper function to select a time
Future<TimeOfDay?> _selectTime(
    BuildContext context, TimeOfDay? selectedTime) async {
  final TimeOfDay? picked = await showTimePicker(
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
  return picked;
}
