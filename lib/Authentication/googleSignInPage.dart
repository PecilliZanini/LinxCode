import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linxflutter/Authentication/authPage.dart';
import 'package:linxflutter/Authentication/google_sign_in_provider.dart';
import 'package:linxflutter/Authentication/loginIn.dart';
import 'package:linxflutter/Authentication/signUp.dart';
import 'package:linxflutter/home.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GoogleSignInPage extends StatefulWidget{
  @override
  _GoogleSignInPage createState() => _GoogleSignInPage();
}

class _GoogleSignInPage extends State<GoogleSignInPage>{
  bool isLogin = true;

  @override
  Widget build(BuildContext context) =>Scaffold(
    body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(), builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
        }else if(snapshot.hasData){
        return HomePage();}
        else if(snapshot.hasError){
          return Center(child: Text("Error"));
        }else return AuthPage();
    },
    ),




  );

}