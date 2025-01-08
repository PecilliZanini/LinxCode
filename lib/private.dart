import 'dart:convert';
import 'dart:ui';
import 'package:favicon/favicon.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:linxflutter/widgets/categoryItemForHome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:linxflutter/Authentication/authPage.dart';
import 'package:linxflutter/Authentication/fingerprintPage.dart';
import 'package:linxflutter/Authentication/google_sign_in_provider.dart';
import 'package:linxflutter/Manager/data_manager.dart';
import 'package:linxflutter/Manager/link_manager.dart';
import 'package:linxflutter/api/localAuthAPI.dart';
import 'package:linxflutter/future.dart';
import 'package:linxflutter/home.dart';
import 'package:linxflutter/private.dart';
import 'package:linxflutter/settings.dart';

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

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PrivatePage(),
    ),
  );
}

class PrivatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PrivatePage();
}

class _PrivatePage extends State<PrivatePage> {
  bool? value = false;
  List<Icon> icons = [
    Icon(FeatherIcons.book),
    Icon(FeatherIcons.tv),
    Icon(FeatherIcons.code),
    Icon(FeatherIcons.compass),
    Icon(FeatherIcons.play),
    Icon(FeatherIcons.activity),
  ];
  String idUser = FirebaseAuth.instance.currentUser!.uid;
  final filter = TextEditingController();
  var user = FirebaseAuth.instance.currentUser!;
  var LinkStream = FirebaseFirestore.instance
      .collection("links")
      .where("idUser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where("isPrivate", isEqualTo: true)
      .snapshots();
  var CategoryStream = FirebaseFirestore.instance
      .collection("categories")
      .where("idUser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.title_private,
                                    style: GoogleFonts.poppins(
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                                SizedBox(
                                  height: 1,
                                ),
                                Text(AppLocalizations.of(context)!.text_private,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black54,
                                        fontSize: 11)),
                              ],
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(
                                FeatherIcons.eye,
                                color: Colors.black54,
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                FeatherIcons.settings,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SettingsPage()),
                                );
                              },
                            ),
                            SizedBox(),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: TextField(
                            controller: filter,
                            onChanged: (filter) => resetStreamWithNameFilter(),
                            decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.search,
                                prefixIcon: Icon(Icons.search),
                                isDense: false,
                                filled: true,
                                prefixIconColor: Colors.black38,
                                hoverColor: Color(0xffF5F5F6),
                                focusColor: Color(0xffF5F5F6),
                                hintStyle: TextStyle(
                                    color: Colors.black45,
                                    fontWeight: FontWeight.w400),
                                fillColor: Color.fromARGB(255, 239, 240, 246),
                                //Colors.white,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(15))),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context)!.on_links,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18)),
                              SizedBox(
                                height: 30,
                              ),
                              StreamBuilder(
                                  stream: LinkStream, //build connection
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot>
                                          streamSnapshot) {
                                    if (streamSnapshot.hasData) {
                                      return ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: streamSnapshot
                                            .data!.docs.length, //number of rows
                                        itemBuilder: (context, index) {
                                          final DocumentSnapshot
                                              documentSnapshot =
                                              streamSnapshot.data!.docs[index];
                                          DataManager.instance.publicLink.add(
                                              Link(
                                                  title:
                                                      documentSnapshot["title"],
                                                  link:
                                                      documentSnapshot["link"],
                                                  isPrivate: documentSnapshot[
                                                      "isPrivate"],
                                                  idUser: documentSnapshot[
                                                      "idUser"],
                                                  idLink: documentSnapshot[
                                                      "idLink"],
                                                  caseSearchList:
                                                      documentSnapshot[
                                                          "caseSearchList"],
                                                  categories: documentSnapshot[
                                                      "categories"],
                                                  urlPNG: documentSnapshot[
                                                      "urlPNG"]));
                                          print("Link di" +
                                              documentSnapshot["title"] +
                                              ": " +
                                              documentSnapshot["urlPNG"]);
                                          return LinkItem(
                                            title: documentSnapshot["title"],
                                            url: documentSnapshot["link"],
                                            documentSnapshot: documentSnapshot,
                                            urlPNG: documentSnapshot["urlPNG"],
                                          );
                                        },
                                      );
                                    } else {
                                      return Center();
                                    }
                                  }),
                              SizedBox(
                                height: 60,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  String checkLink(String url) {
    if (!url.startsWith("https://www.") || !url.startsWith("http://www.")) {
      return "http://www." + url;
    }

    return url;
  }

  Future<void> share(
      String title, String text, String linkUrl, String chooserTitle) async {
    await FlutterShare.share(
        title: title, text: text, chooserTitle: chooserTitle);
  }

  Future<void> _deleteLink(String linkID) async {
    var stream = FirebaseFirestore.instance.collection("links");

    await stream.doc(linkID).delete();
  }

  Future _createLink(
      {required String title,
      required String url,
      required bool? isPrivate,
      required String idUser,
      required String urlPNG,
      required List<String> caseSearchList,
      required List<String> categories}) async {
    final docUser = FirebaseFirestore.instance.collection('links').doc();

    final link = Link(
        title: title,
        link: url,
        urlPNG: _getUrl(),
        isPrivate: isPrivate,
        idUser: idUser,
        idLink: FirebaseFirestore.instance.collection('links').doc().id,
        caseSearchList: caseSearchList,
        categories: categories);

    await docUser.set(link.toJson());
  }

  _getUrl() {
    //Favicon? iconUrl = await FaviconFinder.getBest(url);
    //String? x = iconUrl?.url;
    //if (x != null) {
    // return x;
    //} else {
    return "https://cdn-icons-png.flaticon.com/512/732/732228.png";
    //}
  }

  Future<void> resetStreamWithNameFilter() async {
    setState(() {
      // return all products if your filter is empty
      if (filter.text.isEmpty) {
        LinkStream = FirebaseFirestore.instance
            .collection("links")
            .where("idUser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where("isPrivate", isEqualTo: true)
            .snapshots();
        return;
      }

      // if the filter is not empty, then filter by that field 'nombre'
      LinkStream = FirebaseFirestore.instance
          .collection("links")
          .where("idUser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where("isPrivate", isEqualTo: true)
          .where("caseSearchList", arrayContains: filter.text.toString())
          .snapshots();
      //Filterstream = FirebaseFirestore.instance.collection("links").where("idUser",isEqualTo: FirebaseAuth.instance.currentUser!.uid).where("isPrivate", isEqualTo: false).where(isGreaterThanOrEqualTo: ).snapshots();
    });
  }

  Future<void> loadChip() async {
    var list = FirebaseFirestore.instance
        .collection("links")
        .where("idUser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where("isPrivate", isEqualTo: false)
        .where("caseSearchList", arrayContains: filter.text.toString())
        .get();
    /*for (var Ref in list.) {
      print(Ref.data());
    }*/
  }

  List<String> setSearchParam(String caseNumber) {
    List<String> caseSearchList = [];
    String temp = "";
    for (int i = 0; i < caseNumber.length; i++) {
      temp = temp + caseNumber[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }

  void LoginBioAuth() async {
    final isAuthenticated = await LocalAuthApi.authenticate();

    if (isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PrivatePage()),
      );
    }
  }

  loadImg() {
    if (user.photoURL != null) {
      print(user.photoURL!);
      return NetworkImage(user.photoURL!);
    } else
      return NetworkImage(
          "https://lh3.googleusercontent.com/a-/ACNPEu8Ltr_wLED4Iu73X4PcLmGkw33eodfarUAPrRco=s96-c");
  }

  String ShowDisplayName() {
    if (user.displayName != null) {
      return user.displayName!;
    }
    return "";
  }
}

String? checkInput(String string) {
  if (string.isEmpty || string.length < 2) {
    return "This can't be empty";
  }
  return null;
}

class MySearchDelegate extends SearchDelegate {
  var x = FirebaseFirestore.instance
      .collection("links")
      .where("idUser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where("isPrivate", isEqualTo: false)
      .snapshots();
  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
            onPressed: () {
              if (query.isEmpty) {
                close(context, null);
              } else {
                query = "";
              }
            },
            icon: const Icon(Icons.arrow_back))
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    throw UnimplementedError();
  }
}
