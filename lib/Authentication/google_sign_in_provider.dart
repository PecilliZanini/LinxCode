import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    try {
      print("Starting Google Sign-In process");
      var googleUser = await googleSignIn.signIn();
      print("Google Sign-In completed, user: ${googleUser?.email}");

      if (googleUser == null) {
        print("Sign-In cancelled by user");
        return;
      }

      _user = googleUser;

      print("Authenticating with Google");
      final googleAuth = await googleUser.authentication;
      print("Google authentication completed");

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken
      );

      print("Signing in to Firebase");
      await FirebaseAuth.instance.signInWithCredential(credential);
      print("Firebase sign-in completed");

      notifyListeners();
    } catch (e) {
      print("Error during Google Sign-In: ${e.toString()}");
      if (e is PlatformException) {
        print("Error code: ${e.code}");
        print("Error message: ${e.message}");
        print("Error details: ${e.details}");
      }
    }
  }

  Future logout() async {
    try {
      await googleSignIn.disconnect();
      FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Errore nel logout: " + e.toString());
    }
  }
}
