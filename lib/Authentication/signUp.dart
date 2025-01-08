import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linxflutter/Authentication/loginIn.dart';
import 'package:linxflutter/future.dart';
import 'package:linxflutter/private.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUp extends StatefulWidget {
  final VoidCallback onClickedSignIn;

  const SignUp({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignUp();
}

class _SignUp extends State<SignUp> {
  final emailController = TextEditingController();
  final psswdController = TextEditingController();
  String email = "";
  String psswd = "";

  final formKey = GlobalKey<FormState>();

  void dispose() {
    emailController.dispose();
    psswdController.dispose();

    super.dispose();
  }

  var obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.black),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SafeArea(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: Center(
                  child: SizedBox(
                      height: 200,
                      child: Image.asset('assets/images/signup1.png')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.register,
                        style: GoogleFonts.poppins(
                            fontSize: 37,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 33, 54, 90)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 30),
                        child: TextFormField(
                          validator: (email) =>
                              email != null && !EmailValidator.validate(email)
                                  ? AppLocalizations.of(context)!.valid_email
                                  : null,
                          controller: emailController,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: AppLocalizations.of(context)!.email),
                        ),
                      ),
                      TextFormField(
                          validator: (psswd) => psswd != null &&
                                  !EmailValidator.validate(psswd) &&
                                  psswd.length < 5
                              ? AppLocalizations.of(context)!.valid_password
                              : null,
                          controller: psswdController,
                          obscureText: obscureText,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_rounded),
                              suffixIcon: GestureDetector(
                                child: obscureText
                                    ? Icon(Icons.visibility_off)
                                    : Icon(Icons.visibility),
                                onTap: () {
                                  setState(() {
                                    obscureText = !obscureText;
                                  });
                                },
                              ),
                              hintText: AppLocalizations.of(context)!.password))
                    ],
                  ),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                      child: Column(
                        children: [
                          SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  final isValidForm =
                                      formKey.currentState!.validate();
                                  if (isValidForm) {
                                    signUp();
                                  }
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.register,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color.fromARGB(255, 0, 101, 255)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13))),
                                    shadowColor: MaterialStateProperty.all(
                                        Colors.transparent)),
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            child: GestureDetector(
                              child: Text(
                                AppLocalizations.of(context)!.login,
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 0, 101, 255)),
                              ),
                              onTap: widget.onClickedSignIn,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          )),
        ),
      ),
    );
  }

  Future signUp() async {
    //showDialog(context: context,barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator()));

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: psswdController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.code);
      return Center(child: Text("Error"));
    }
  }

  login() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => LoginPage(
                onClickedSignUp: () {},
              )),
    );
  }
}
