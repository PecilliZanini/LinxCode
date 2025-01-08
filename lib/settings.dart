import 'dart:convert';
import 'dart:ui';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:linxflutter/Authentication/authPage.dart';
import 'package:linxflutter/Authentication/fingerprintPage.dart';
import 'package:linxflutter/Authentication/google_sign_in_provider.dart';
import 'package:linxflutter/Manager/data_manager.dart';
import 'package:linxflutter/Manager/event_listener.dart';
import 'package:linxflutter/Manager/event_manager.dart';
import 'package:linxflutter/Manager/link_manager.dart';
import 'package:linxflutter/api/localAuthAPI.dart';
import 'package:linxflutter/future.dart';
import 'package:linxflutter/home.dart';
import 'package:linxflutter/main.dart';
import 'package:linxflutter/private.dart';
import 'package:linxflutter/widgets/categoryItemForCreate.dart';
import 'package:linxflutter/widgets/categoryItemForHome.dart';
import 'package:linxflutter/widgets/linkItem.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_share/flutter_share.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:firebase_core/firebase_core.dart';

import 'package:linxflutter/Manager/link_manager.dart';

import 'package:linxflutter/Manager/category_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseDatabase.instance.setPersistenceEnabled(true);
  FirebaseFirestore.instance.settings =
      Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

  try {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
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
  } catch (e) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    print(e.toString());
  }
}

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsPage();
  var user = FirebaseAuth.instance.currentUser!;
}

class _SettingsPage extends State<SettingsPage> {
  var user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    return ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
        builder: (context, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                  statusBarIconBrightness: Brightness.dark,
                  statusBarColor: Colors.white),
              child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: //Color.fromARGB(255, 248, 248, 250),
                      Colors.white,
                  body: SafeArea(
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child: SingleChildScrollView(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: loadImg(),
                                    radius: 25,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Hey " +
                                              getName()!
                                              //Text("Hey ",
                                              //+
                                              //ShowDisplayName()
                                              //user.displayName! +
                                              +
                                              "👋",
                                          style: GoogleFonts.poppins(
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      SizedBox(
                                        height: 1,
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  IconButton(
                                    icon: Icon(
                                      FeatherIcons.home,
                                      color: Colors.black54,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()),
                                      );
                                    },
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(children: [
                                Text("Logout",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black54)),
                                IconButton(
                                    onPressed: () async {
                                      try {
                                        final provider =
                                            Provider.of<GoogleSignInProvider>(
                                                context,
                                                listen: false);
                                        FirebaseAuth.instance.signOut();
                                        provider.logout();
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) => MainPage()),
                                        );
                                      } catch (e) {
                                        print(
                                            "Errore nel logout" + e.toString());
                                      }
                                    },
                                    icon: Icon(
                                      FeatherIcons.logOut,
                                      color: Colors.black54,
                                    )),
                              ]),
                              SizedBox(
                                height: 20,
                              ),
                              Row(children: [
                                Text(AppLocalizations.of(context)!.rate_us,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black54)),
                                IconButton(
                                    onPressed: () async {
                                      try {
                                        launchUrl(Uri.parse(
                                            "https://play.google.com/store/apps/details?id=pecilli.zanini.linx"));
                                      } catch (e) {
                                        print(
                                            "Errore nel logout" + e.toString());
                                      }
                                    },
                                    icon: Icon(
                                      FeatherIcons.star,
                                      color: Colors.black54,
                                    )),
                              ]),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Text("Privacy",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54)),
                                  IconButton(
                                      onPressed: () async {
                                        try {
                                          launchUrl(Uri.parse(
                                              "https://sites.google.com/view/linx-privacy-policy/"));
                                        } catch (e) {
                                          print("Errore nel logout" +
                                              e.toString());
                                        }
                                      },
                                      icon: Icon(
                                        Icons.policy,
                                        color: Colors.black54,
                                      ))
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Text("Info",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54)),
                                  IconButton(
                                      onPressed: () async {
                                        showAboutDialog(
                                            context: context,
                                            applicationVersion: "Version 2.0",
                                            applicationLegalese:
                                                "Linx packages",
                                            applicationName: "Linx");
                                      },
                                      icon: Icon(
                                        FeatherIcons.info,
                                        color: Colors.black54,
                                      ))
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Text(AppLocalizations.of(context)!.website,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54)),
                                  IconButton(
                                      onPressed: () async {
                                        try {
                                          launchUrl(Uri.parse(
                                              "https://pecillizanini.github.io/"));
                                        } catch (e) {
                                          print("Errore nel logout" +
                                              e.toString());
                                        }
                                      },
                                      icon: Icon(
                                        FeatherIcons.loader,
                                        color: Colors.black54,
                                      )),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Text(
                                      AppLocalizations.of(context)!
                                          .forgot_password,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54)),
                                  IconButton(
                                      onPressed: () async {
                                        resetPsswd();
                                      },
                                      icon: Icon(
                                        FeatherIcons.key,
                                        color: Colors.black54,
                                      )),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Text(
                                      AppLocalizations.of(context)!
                                          .terms_to_see,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54)),
                                  IconButton(
                                      onPressed: () async {
                                        try {
                                          launchUrl(Uri.parse(
                                              "https://sites.google.com/view/terms-conditions-linx/"));
                                        } catch (e) {
                                          print("Errore nel logout" +
                                              e.toString());
                                        }
                                      },
                                      icon: Icon(
                                        FeatherIcons.zoomIn,
                                        color: Colors.black54,
                                      )),
                                ],
                              ),
                              SizedBox(
                                height: 100,
                              ),
                            ],
                          ))))));
        });
  }

  loadImg() {
    if (user.photoURL != null) {
      print(user.photoURL!);
      return NetworkImage(user.photoURL!);
    } else
      return NetworkImage(
          "https://lh3.googleusercontent.com/a-/ACNPEu8Ltr_wLED4Iu73X4PcLmGkw33eodfarUAPrRco=s96-c");
  }

  Future resetPsswd() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: FirebaseAuth.instance.currentUser!.email!);
      Navigator.of(context).popUntil((route) => route.isFirst);
      Fluttertoast.showToast(msg: 'Check your spam');
    } on FirebaseAuthException catch (e) {
      print(e);

      Navigator.of(context).pop();
      return SnackBar(content: Text(e.toString()));
    }
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  String? getName() {
    if ((user.displayName) != null) {
      var x = user.displayName;

      if (x.toString().length > 15) {
        return x.toString().substring(0, 12) + "...";
      } else {
        return x.toString();
      }
    } else {
      return "";
    }
  }
}
