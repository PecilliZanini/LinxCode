import 'dart:async';
import 'dart:ui';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:is_first_run/is_first_run.dart';
import 'package:linxflutter/Authentication/authPage.dart';
import 'package:linxflutter/Authentication/loginIn.dart ';
import 'package:linxflutter/Authentication/verifyEmail.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:linxflutter/Manager/data_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Future.delayed(Duration(seconds: 3));
  FlutterNativeSplash.remove();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyB3YX_Og-GRwrNpzVIQOxvdAe0jjdfVdjQ",
      appId: "1:484140686895:web:0d68f54b6063d711a0b0da",
      messagingSenderId: "Messaging sender id here",
      projectId: "linx-7d3b6",
    ),
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      theme: ThemeData(
        canvasColor: Colors.transparent,
        useMaterial3: true,
      ),
      supportedLocales: [
        Locale('en'),
        Locale('it'),
        Locale('es'),
        Locale('fr'),
        Locale('de'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
    ),
  );
}

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late StreamSubscription _intentData;
  String? data;

  @override
  void initState() {
    super.initState();

    /*_intentData = ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        try {
          data = value;
          print("-----------------------------------------------Passa2 con" +
              data!);
          DataManager.instance.setDataIntent(data);
          print("-----------------------------------------------Passa22 con" +
              data!);
        } catch (e) {
          e.toString();
        }
      });
    });

    ReceiveSharingIntent.getInitialText().then((String? value) {
      setState(() {
        try {
          data = value;
          print("-----------------------------------------------Passa2 con" +
              data!);
          DataManager.instance.setDataIntent(data);
          print("-----------------------------------------------Passa22 con" +
              data!);
        } catch (e) {
          e.toString();
        }
      });
    });*/
  }

  @override
  void dispose() {
    _intentData.cancel();
    DataManager.instance.setDataIntent("");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Si è verificato un errore"));
          } else if (snapshot.hasData) {
            return VerifyEmail();
          } else {
            return AuthPage();
          }
        },
      ),
    );
  }
}
