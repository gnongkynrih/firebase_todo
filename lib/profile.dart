import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_todo/models/profile.dart';
import 'package:firebase_todo/provider/task_provider.dart';
import 'package:firebase_todo/widget/select_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  ProfileModel? profile = ProfileModel.defaultValue();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  bool isSaving = false;
  bool isLoading = true;

  getData() async {
    final DocumentSnapshot snapshot =
        await db.collection('profile').doc(auth.currentUser!.uid).get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      Provider.of<TaskProvider>(context, listen: false)
          .updateProfileData(data['image']);

      setState(() {
        profile!.name = data['name'];
        profile!.phone = data['phone'];
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getData();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // Provider.of<TaskProvider>(context, listen: false).updateCurrentTabIndex(1);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    Stack(
                      children: [
                        Provider.of<TaskProvider>(context, listen: true)
                                .profilePicture
                                .isNotEmpty
                            ? CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(
                                    Provider.of<TaskProvider>(context,
                                            listen: true)
                                        .profilePicture),
                              )
                            : const CircleAvatar(
                                radius: 50,
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: -10,
                          child: IconButton(
                            onPressed: () {
                              photoOption(context);
                            },
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: profile!.name,
                            keyboardType: TextInputType.name,
                            decoration: const InputDecoration(
                              hintText: 'Name',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                            onSaved: (String? name) {
                              profile!.name = name!;
                            },
                          ),
                          TextFormField(
                            initialValue: profile!.phone,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: 'Phone',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                            onSaved: (String? phone) {
                              profile!.phone = phone!;
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {
                              saveProfile();
                            },
                            child: isSaving
                                ? const Text('Please wait')
                                : const Text('Save'),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  void photoOption(BuildContext context) async {
    var response = await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return const SizedBox(height: 300, child: SelectImage());
        });
  }

  saveProfile() async {
    try {
      setState(() {
        isSaving = true;
      });
      if (formKey.currentState!.validate()) {
        //save the form
        formKey.currentState!.save();

        //save profile to firestore
        final Map<String, dynamic> data = {
          'name': profile!.name,
          'phone': profile!.phone
        };
        await db.collection('profile').doc(auth.currentUser!.uid).update(data);
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }
}
