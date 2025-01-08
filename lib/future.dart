import 'dart:convert';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:linxflutter/Authentication/fingerprintPage.dart';
import 'package:linxflutter/Manager/data_manager.dart';
import 'package:linxflutter/api/localAuthAPI.dart';
import 'package:linxflutter/main.dart';
import 'package:linxflutter/private.dart';

import 'Manager/link_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(

  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FuturePage(),),);
}
class FuturePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _FuturePage();
}

class _FuturePage extends State<FuturePage> {

  int _selectedIndex = 2;

  void LoginBioAuth() async{
    final isAuthenticated = await LocalAuthApi.authenticate();

    if (isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => PrivatePage()),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainPage())
        );
        break;
      case 1:
            LoginBioAuth();
            break;
    }



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false, // <-- Step 2. SEE HERE

        title: Text(DataManager.instance.getDataIntent().toString()),
      ),
      bottomNavigationBar:

      BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style),
            label: 'Private',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_forward_ios_sharp),
            label: 'Future',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),

    );

  }



}
