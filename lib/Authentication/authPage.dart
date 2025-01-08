import 'package:flutter/material.dart';
import 'package:linxflutter/Authentication/loginIn.dart';
import 'package:linxflutter/Authentication/signUp.dart';

class AuthPage extends StatefulWidget{
  @override
    _AuthPageState createState() => _AuthPageState();
  }

class _AuthPageState extends State<AuthPage>{
  bool isLogin = true;

  @override
  Widget build(BuildContext context) => isLogin
        ? LoginPage(onClickedSignUp : toggle)
        : SignUp(onClickedSignIn : toggle);

  void toggle() => setState(() => isLogin = !isLogin);

}