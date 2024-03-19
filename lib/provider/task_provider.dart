import 'package:firebase_todo/models/todo.dart';
import 'package:flutter/material.dart';

class TaskProvider with ChangeNotifier {
  List<TodoModel> todoList = [];
  int currentTabIndex = 0;

  void setTodoList(TodoModel todo) {
    todoList.add(todo);
    notifyListeners();
  }

  void updateCurrentTabIndex(int index) {
    currentTabIndex = index;
    notifyListeners();
  }
}
