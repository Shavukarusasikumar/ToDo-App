// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class toDo {
  String title;
  bool iscompleted = false;
  DateTime? dueDate;
  TimeOfDay? dueTime;
  String? description;
  toDo({
    required this.title,
    required this.iscompleted,
    required this.dueDate,
    required this.dueTime,
    required this.description,
  });
}
