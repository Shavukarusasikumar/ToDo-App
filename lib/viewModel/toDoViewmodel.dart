import 'package:flutter/material.dart';
import 'package:todo/model/toDoModel.dart';

class todoViewModel extends ChangeNotifier {
  List<toDo> _toDos = [];
  List<toDo> get todos => _toDos;

  List<toDo> get incompleteToDos =>
      _toDos.where((todo) => !todo.iscompleted).toList();

  List<toDo> get completedToDos =>
      _toDos.where((todo) => todo.iscompleted).toList();

  void addToDo(
      String title, DateTime date, TimeOfDay time, String description) {
    _toDos.add(toDo(
      title: title,
      iscompleted: false,
      dueDate: date,
      dueTime: time,
      description: description,
    ));
    notifyListeners();
  }


  void editTodo(int index, String newTitle, DateTime newDate, TimeOfDay newTime, String newDescription) {
    final todo = _toDos[index];
    if (!todo.iscompleted) {
      todo.title = newTitle;
      todo.dueDate = newDate;
      todo.dueTime = newTime;
      todo.description = newDescription;
      notifyListeners();
    }
  }

  void toggleCompletion(toDo todo) {
    todo.iscompleted = !todo.iscompleted;
    notifyListeners();
  }

  void toDodeletion(int index) {
    _toDos.removeAt(index);
    notifyListeners();
  }
}
