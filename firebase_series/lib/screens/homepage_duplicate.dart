import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_series/screens/email_auth/loginscreen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  XFile? profilePic;

  Future<void> chooseImageFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        profilePic = pickedImage;
      });
    } else {
      print('No image selected');
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<void> saveUser() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String ageString = ageController.text.trim();

    int age = int.parse(ageString);

    nameController.clear();
    emailController.clear();
    ageController.clear();

    if (name != "" && email != "" && age != "" && profilePic != null) {
      Future<void>.delayed(Duration.zero, () async {
        File imageFile = File(profilePic!.path);
        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child("profilePictures")
            .child(Uuid().v1())
            .putFile(imageFile);

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        Map<String, dynamic> userData = {
          'name': name,
          'email': email,
          'age': age,
          'profilePic': downloadUrl,
        };

        await FirebaseFirestore.instance.collection('users').add(userData);

        setState(() {
          profilePic = null;
        });
      });
    } else {
      print('Please fill all the form');
    }
  }

  void deleteDocument(String documentId) {
    FirebaseFirestore.instance.collection('users').doc(documentId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello'),
        actions: [
          IconButton(
              onPressed: () {
                signOut();
              },
              icon: Icon(Icons.logout)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: chooseImageFromGallery,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  backgroundImage: profilePic != null
                      ? FileImage(File(profilePic!.path))
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  saveUser();
                },
                child: Text("Save"),
              ),
              SizedBox(height: 30.0),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('age')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Expanded(
                        child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              String documentId = snapshot.data!.docs[index].id;
                              Map<String, dynamic> userMap =
                                  snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;
                              return ListTile(
                                title: Text(
                                    userMap['name'] + '(${userMap['age']})'),
                                subtitle: Text(userMap['email']),
                                trailing: IconButton(
                                    onPressed: () {
                                      deleteDocument(documentId);
                                    },
                                    icon: Icon(Icons.delete)),
                              );
                            }),
                      );
                    } else {
                      return Text('No Data!');
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
