import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_todo/models/todo.dart';
import 'package:firebase_todo/provider/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final myForm = GlobalKey<FormState>();
  TodoModel todo = TodoModel(task: '', isCompleted: false, uid: '');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Todo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: myForm,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Task',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onSaved: (newValue) => todo.task = newValue!,
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.purpleAccent,
            // padding: const EdgeInsets.all(15),
          ),
          onPressed: () {
            insertData();
          },
          child: const Text('Submit'),
        ),
      ),
    );
  }

  void insertData() async {
    if (myForm.currentState!.validate()) {
      myForm.currentState!.save();

      //get the user id
      FirebaseAuth auth = FirebaseAuth.instance;
      todo.uid = auth.currentUser!.uid;
      //save into the firebase
      FirebaseFirestore firebase = FirebaseFirestore.instance;
      var data = {
        'task': todo.task,
        'isCompleted': todo.isCompleted,
        'uid': todo.uid,
      };
      await firebase.collection('todo').add(data);

      //update the provider task list
      Provider.of<TaskProvider>(context, listen: false).addTodoList(todo);
      Navigator.pop(context, todo);
    }
  }
}
