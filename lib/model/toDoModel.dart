import 'package:flutter/material.dart';

class toDo {
  String title;
  bool iscompleted;
  DateTime dueDate;
  TimeOfDay dueTime;
  String description;

  toDo({
    required this.title,
    required this.iscompleted,
    required this.dueDate,
    required this.dueTime,
    required this.description,
  });

 
  Map<String, dynamic> toJson() => {
        'title': title,
        'iscompleted': iscompleted,
        'dueDate': dueDate.toIso8601String(),
        'dueTime': '${dueTime.hour}:${dueTime.minute}',
        'description': description,
      };

  static toDo fromJson(Map<String, dynamic> json) {
    final timeParts = json['dueTime'].split(':');
    return toDo(
      title: json['title'],
      iscompleted: json['iscompleted'],
      dueDate: DateTime.parse(json['dueDate']),
      dueTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      description: json['description'],
    );
  }
}
