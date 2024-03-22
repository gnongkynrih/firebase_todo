import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_todo/auth/signup.dart';
import 'package:firebase_todo/models/user.dart';
import 'package:firebase_todo/screen/todo_list.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var formKey = GlobalKey<FormState>();

  UserSchema? user = UserSchema.defaultValue();
  FirebaseAuth auth = FirebaseAuth.instance;
  bool invalidCredentials = false;
  bool isLogin = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Login',
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    //check if the value is valid email id
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Please enter a valid email id';
                    }
                    return null;
                  },
                  onSaved: (String? email) {
                    user!.email = email!;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Password required';
                    }
                    return null;
                  },
                  onSaved: (String? password) {
                    user!.password = password!;
                  },
                ),
                invalidCredentials
                    ? const Text(
                        'Invalid credentials',
                        style: TextStyle(color: Colors.redAccent),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => const SignupScreen()));
                        },
                        child: const Text('Register'),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLogin = true;
                          });
                          login();
                        },
                        child: isLogin
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Login'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void login() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        await auth.signInWithEmailAndPassword(
            email: user!.email, password: user!.password);
        setState(() {
          isLogin = false;
        });
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (builder) => const TodoListScreen()));
      } catch (e) {
        setState(() {
          invalidCredentials = true;
        });
        print(e);
      } finally {
        setState(() {
          isLogin = false;
        });
      }
    }
  }
}
