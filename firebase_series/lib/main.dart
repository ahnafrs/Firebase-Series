import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_series/firebase_options.dart';
import 'package:firebase_series/screens/homepage.dart';
import 'package:firebase_series/screens/phone_auth/phone_number_login_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // QuerySnapshot snapshot =
  //     await FirebaseFirestore.instance.collection("users").get();
  // for (var doc in snapshot.docs) {
  //   print(doc.data().toString());
  // }

  // DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //     .collection("users")
  //     .doc('pWib9diKJtleD8yaAQrB')
  //     .get();

  // print(snapshot.data().toString());
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> newUserData = {
    "name": "Pokemon",
    "email": "pokemon@gmail.com"
  };
  await _firestore.collection('users').doc('your-id-here').update({
    'email': 'pokemonfusion@gmail.com',
  });
  print("Update user saved");
  // await _firestore.collection('users').add(newUserData);
  // print("new user saved");

  // await _firestore.collection('users').doc('your-id-here').set(newUserData);
  // print("new user saved");
  // await _firestore.collection('users').doc('VOolH2q3bf8GZS4WwMdu').delete();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: (FirebaseAuth.instance.currentUser != null)
          ? HomePage()
          : PhoneLoginScreen(),
    );
  }
}
