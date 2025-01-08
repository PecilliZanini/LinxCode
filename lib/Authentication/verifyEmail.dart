import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linxflutter/home.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VerifyEmail extends StatefulWidget {
  @override
  _VerifyEmail createState() => _VerifyEmail();
}

class _VerifyEmail extends State<VerifyEmail> {
  final formKey = GlobalKey<FormState>();
  bool isVerified = false;

  void initState() {
    super.initState();

    isVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isVerified) {
      sendEmail();

      (_) => checkEmailVerified();
    }
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => isVerified
      ? HomePage()
      : Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
              child: Form(
                key: formKey,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: Center(
                          child: SizedBox(
                              height: 200,
                              child: Image.asset('assets/images/login3.png')),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                              AppLocalizations.of(context)!.email_sended,
                              style: GoogleFonts.poppins(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54))),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: sendEmail,
                        icon: Icon(Icons.email),
                        label: Text(
                          'Resend email',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        child: Text(
                          "Back",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Theme.of(context).colorScheme.background,
                              fontSize: 20),
                        ),
                        onTap: () => FirebaseAuth.instance.signOut(),
                      ),
                    ],
                  ),
                ),
              )));

  Future sendEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
  }
}
