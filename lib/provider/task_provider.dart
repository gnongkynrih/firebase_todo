import 'package:firebase_todo/models/todo.dart';
import 'package:flutter/material.dart';

class TaskProvider with ChangeNotifier {
  List<TodoModel> todoList = [];
  int currentTabIndex = 0;
  String profilePicture = '';

  void addTodoList(TodoModel todo) {
    todoList.add(todo);
    notifyListeners();
  }

  void updateTodoStatus(int index, bool status) {
    todoList[index].isCompleted = status;
    notifyListeners();
  }

  void updateCurrentTabIndex(int index) {
    currentTabIndex = index;
    notifyListeners();
  }

  void updateProfileData(String profile) {
    profilePicture = profile;
    notifyListeners();
  }
}
