import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/model/toDoModel.dart';

class todoViewModel extends ChangeNotifier {
  List<toDo> _toDos = [];

  List<toDo> get todos => _toDos;

  List<toDo> get incompleteToDos =>
      _toDos.where((todo) => !todo.iscompleted).toList();

  List<toDo> get completedToDos =>
      _toDos.where((todo) => todo.iscompleted).toList();

  todoViewModel() {
    _loadToDos();
  }

  void addToDo(
      String title, DateTime date, TimeOfDay time, String description) {
    _toDos.add(toDo(
      title: title,
      iscompleted: false,
      dueDate: date,
      dueTime: time,
      description: description,
    ));
    _saveToDos();
    notifyListeners();
  }

  void editTodo(int index, String newTitle, DateTime newDate,
      TimeOfDay newTime, String newDescription) {
    final todo = _toDos[index];
    if (!todo.iscompleted) {
      todo.title = newTitle;
      todo.dueDate = newDate;
      todo.dueTime = newTime;
      todo.description = newDescription;
      _saveToDos();
      notifyListeners();
    }
  }

  void toggleCompletion(toDo todo) {
    todo.iscompleted = !todo.iscompleted;
    _saveToDos();
    notifyListeners();
  }

  void toDodeletion(int index) {
    _toDos.removeAt(index);
    _saveToDos();
    notifyListeners();
  }

  Future<void> _saveToDos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> toDoJson =
        _toDos.map((todo) => jsonEncode(todo.toJson())).toList();
    prefs.setStringList('todos', toDoJson);
  }

  Future<void> _loadToDos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? toDoJson = prefs.getStringList('todos');
    if (toDoJson != null) {
      _toDos = toDoJson
          .map((todoString) => toDo.fromJson(jsonDecode(todoString)))
          .toList();
    }
    notifyListeners();
  }
}
