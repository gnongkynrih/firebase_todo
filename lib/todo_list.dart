import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_todo/add.dart';
import 'package:firebase_todo/models/todo.dart';
import 'package:firebase_todo/provider/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  Future<void> getTodoList() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    CollectionReference ref = FirebaseFirestore.instance.collection('todo');
    var data = await ref.where('uid', isEqualTo: auth.currentUser!.uid).get();
    for (var element in data.docs) {
      TodoModel todo = TodoModel(
          task: element['task'],
          uid: element['uid'] ?? '',
          isCompleted: element['isCompleted']);
      Provider.of<TaskProvider>(context, listen: false).setTodoList(todo);
    }
  }

  @override
  void didChangeDependencies() {
    // Provider.of<TaskProvider>(context, listen: false).updateCurrentTabIndex(0);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    getTodoList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth auth = FirebaseAuth.instance;
              auth.signOut();
              Navigator.pushNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
          child: ListView.builder(
        itemCount:
            Provider.of<TaskProvider>(context, listen: true).todoList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              title: Text(Provider.of<TaskProvider>(context, listen: true)
                  .todoList[index]
                  .task),
              trailing: IconButton(
                icon: Icon(Provider.of<TaskProvider>(context, listen: true)
                        .todoList[index]
                        .isCompleted
                    ? Icons.check_box
                    : Icons.check_box_outline_blank),
                onPressed: () async {
                  FirebaseFirestore firestore = FirebaseFirestore.instance;
                  final data = await firestore
                      .collection('todo')
                      .where('uid',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .where('task',
                          isEqualTo:
                              Provider.of<TaskProvider>(context, listen: false)
                                  .todoList[index]
                                  .task)
                      .get();

                  for (var element in data.docs) {
                    bool complete =
                        Provider.of<TaskProvider>(context, listen: false)
                            .todoList[index]
                            .isCompleted;
                    Provider.of<TaskProvider>(context, listen: false)
                        .updateTodoStatus(index, !complete);
                    await firestore.collection('todo').doc(element.id).update({
                      'isCompleted': !complete,
                    });
                  }
                },
              ));
        },
      )),
      floatingActionButton: IconButton(
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.purple,
          padding: const EdgeInsets.all(15),
        ),
        color: Colors.white,
        icon: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) => const AddTodoScreen(),
            ),
          );
        },
      ),
    );
  }
}
