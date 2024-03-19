import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_todo/auth/login.dart';
import 'package:firebase_todo/models/user.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  var formKey = GlobalKey<FormState>();

  UserModel? user = UserModel.defaultValue();
  FirebaseAuth auth = FirebaseAuth.instance;
  bool passwordMismatch = false;

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
                  'Sign Up',
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
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Password should be atleast 6 characters long';
                    }
                    return null;
                  },
                  onSaved: (String? password) {
                    user!.password = password!;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Confirm Password',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    return null;
                  },
                  onSaved: (String? confirmPassword) {
                    user!.confirmPassword = confirmPassword!;
                  },
                ),
                passwordMismatch
                    ? const Text(
                        'Password mismatch',
                        style: TextStyle(color: Colors.redAccent),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        signup();
                      },
                      child: const Text('Sign Up'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signup() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (user!.password != user!.confirmPassword) {
        setState(() {
          passwordMismatch = true;
        });
        AnimatedSnackBar.rectangle(
          'Notification',
          'Password mismatch',
          type: AnimatedSnackBarType.info,
          brightness: Brightness.light,
        ).show(
          context,
        );
        return;
      } else {
        UserCredential data = await auth.createUserWithEmailAndPassword(
            email: user!.email, password: user!.password);

        //create the profile for the person
        FirebaseFirestore db = FirebaseFirestore.instance;
        await db.collection('profile').doc(data.user!.uid).set({
          'name': '',
          'phone': '',
          'email': user!.email,
        });

        setState(() {
          passwordMismatch = false;
        });
      }
    }
  }
}
