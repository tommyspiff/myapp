import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:myapp/authentication.dart';
import 'root_page.dart';

void main() {
  fb.initializeApp(
    apiKey: "AIzaSyAs8g54TwSqnYdP9nAhS0OQ9y-x_bAr7TY",
    authDomain: "myapp-e34fc.firebaseapp.com",
    databaseURL: "https://myapp-e34fc.firebaseio.com",
    projectId: "myapp-e34fc",
    storageBucket: "myapp-e34fc.appspot.com",
    messagingSenderId: "622875596206",
    appId: "1:622875596206:web:3d30d0a0ce3ed08395e43f",
    measurementId: "G-RCXTVH24K7");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RootPage(auth: new Auth())
    );
  }
}
