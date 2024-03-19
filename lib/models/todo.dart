class TodoModel {
  String task;
  bool isCompleted;
  String uid;
  TodoModel({
    required this.task,
    this.isCompleted = false,
    required this.uid,
  });
}
