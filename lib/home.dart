import 'dart:convert';
import 'dart:ui';
import 'package:email_validator/email_validator.dart';
import 'package:eventify/eventify.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
import 'package:linxflutter/Manager/event_listener.dart';
import 'package:linxflutter/Manager/event_manager.dart';
import 'package:linxflutter/Manager/link_manager.dart';
import 'package:linxflutter/api/localAuthAPI.dart';
import 'package:linxflutter/future.dart';
import 'package:linxflutter/home.dart';
import 'package:is_first_run/is_first_run.dart';
import 'package:linxflutter/private.dart';
import 'package:linxflutter/settings.dart';
import 'package:favicon/favicon.dart';
import 'package:linxflutter/widgets/categoryItemForCreate.dart';
import 'package:linxflutter/widgets/categoryItemForHome.dart';
import 'package:linxflutter/widgets/linkItem.dart';
import 'package:linxflutter/widgets/toggleButton.dart';
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

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  bool? value = false;
  String idUser = FirebaseAuth.instance.currentUser!.uid;
  final filter = TextEditingController();
  var user = FirebaseAuth.instance.currentUser!;
  String titleToCheck = "";
  String linkToCheck = "";
  final formKey = GlobalKey<FormState>();
  List<Icon> icons = [
    Icon(FeatherIcons.book),
    Icon(FeatherIcons.tv),
    Icon(FeatherIcons.code),
    Icon(FeatherIcons.compass),
    Icon(FeatherIcons.play),
    Icon(FeatherIcons.activity),
  ];

  var LinkStream = FirebaseFirestore.instance
      .collection("links")
      .where("idUser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where("isPrivate", isEqualTo: false)
      .snapshots();
  var CategoryStream = FirebaseFirestore.instance
      .collection("categories")
      .where("idUser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  var FolderStream =
      FirebaseFirestore.instance.collection("folders").snapshots();

  bool? _isFirstRun;

  final psswdController = TextEditingController();
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
              floatingActionButton: Visibility(
                visible: !keyboardIsOpen,
                child: FloatingActionButton(
                    onPressed: () => _createLinkTab(""),
                    child: Icon(Icons.add)),
              ),
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
                                    "Hey " +
                                        //ShowDisplayName()
                                        //user.displayName! +
                                        "👋",
                                    style: GoogleFonts.poppins(
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                SizedBox(
                                  height: 1,
                                ),
                                Text(AppLocalizations.of(context)!.text_home,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black54)),
                              ],
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(
                                FeatherIcons.eyeOff,
                                color: Colors.black54,
                              ),
                              onPressed: () => LoginBioAuth(),
                            ),
                            //SizedBox(),
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
                        Row(
                          children: [
                            Text(AppLocalizations.of(context)!.categories,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600, fontSize: 18)),
                            Spacer(),
                            GestureDetector(
                              child: Text(
                                  AppLocalizations.of(context)!
                                      .create_categories,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 0, 101, 255))),
                              onTap: _createCategoryTab,
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: EdgeInsets.all(0.0),
                          height: 100,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                StreamBuilder(
                                    stream: CategoryStream, //build connection
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot>
                                            streamSnapshot) {
                                      if (streamSnapshot.hasData) {
                                        return ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemCount: streamSnapshot.data!.docs
                                              .length, //number of rows
                                          itemBuilder: (context, index) {
                                            final DocumentSnapshot
                                                documentSnapshot =
                                                streamSnapshot
                                                    .data!.docs[index];
                                            return CategoryItemForHome(
                                                intIconToUse: icons[
                                                    documentSnapshot["icon"]],
                                                id: documentSnapshot,
                                                title:
                                                    documentSnapshot["name"]);
                                          },
                                        );
                                      } else {
                                        print("Vuotooooooonbe");
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    }),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
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
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
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
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() async {
          bool x = await IsFirstRun.isFirstCall();
          if (x) {
            showTerms();
          }

          if (DataManager.instance.getDataIntent() != "") {
            _createLinkTabDirectShare(DataManager.instance.getDataIntent());
          }
        }));
  }

  String checkLink(String url) {
    if (!url.startsWith("https://www.") &&
        !url.startsWith("http://www.") &&
        !url.startsWith("https://") &&
        !url.startsWith("http://")) {
      return "http://www." + url;
    }

    return url;
  }

  Future<void> _createLink(
      {required String title,
      required String url,
      required bool? isPrivate,
      required String idUser,
      required String urlPNG,
      required List<dynamic> caseSearchList,
      required List<String> categories}) async {
    final docUser = FirebaseFirestore.instance.collection('links').doc();

    final link = Link(
        title: title,
        urlPNG: urlPNG,
        link: url,
        isPrivate: isPrivate,
        idUser: idUser,
        idLink: FirebaseFirestore.instance.collection('links').doc().id,
        caseSearchList: caseSearchList,
        categories: categories);

    await docUser.set(link.toJson());
  }

  Future _createCategories(
      {required String name,
      required String idUser,
      required int icon,
      required List<dynamic> caseSearchList}) async {
    final docUser = FirebaseFirestore.instance.collection('categories').doc();

    final category = Category(
        idCategory: FirebaseFirestore.instance.collection('links').doc().id,
        name: name,
        idUser: idUser,
        icon: icon,
        caseSearchList: caseSearchList);

    docUser.set(category.toJson());
    Navigator.of(context).pop();
  }

  Future<void> resetStreamWithNameFilter() async {
    setState(() {
      print(DataManager.instance.categoryFilter);
      // return all products if your filter is empty
      if (filter.text.isEmpty) {
        LinkStream = FirebaseFirestore.instance
            .collection("links")
            .where("idUser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where("isPrivate", isEqualTo: false)
            .snapshots();
        return;
      }

      // if the filter is not empty, then filter by that field 'nombre'
      LinkStream = FirebaseFirestore.instance
          .collection("links")
          .where("idUser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where("isPrivate", isEqualTo: false)
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

  Future<void> _createLinkTab(String? urlShared) async {
    final title = TextEditingController();
    final url = TextEditingController();
    bool? isPrivate = false;
    List<String> categories = <String>[];
    if (urlShared != null && urlShared.isNotEmpty) {
      url.text = urlShared;
    }
    DataManager.instance.categoriesToUse = categories;

    var CategoryStream = FirebaseFirestore.instance
        .collection("categories")
        .where("idUser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter state) {
            return Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                height: MediaQuery.of(ctx).viewInsets.bottom + 600,
                child: Padding(
                    padding: EdgeInsets.only(
                        top: 25, left: 25, right: 25, bottom: 0),
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: formKey,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.create,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 25,
                                    color: Color.fromARGB(255, 0, 70, 175))),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              AppLocalizations.of(context)!.title,
                              style: GoogleFonts.poppins(
                                  fontSize: 19, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            TextFormField(
                              controller: title,
                              validator: (titleToCheck) => titleToCheck !=
                                          null &&
                                      titleToCheck.length < 1
                                  ? AppLocalizations.of(context)!.empty_title
                                  : null,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(15),
                                  hintText: AppLocalizations.of(context)!.title,
                                  isDense: true,
                                  filled: true,
                                  icon: FaIcon(FontAwesomeIcons.pen),
                                  prefixIconColor: Colors.black38,
                                  hoverColor: Color(0xffF5F5F6),
                                  focusColor: Color(0xffF5F5F6),
                                  hintStyle: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w400),
                                  fillColor: Color.fromARGB(255, 241, 241, 254),
                                  //Colors.white,
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(15))),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              AppLocalizations.of(context)!.url,
                              style: GoogleFonts.poppins(
                                  fontSize: 19, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            TextFormField(
                              controller: url,
                              validator: (linkToCheck) =>
                                  linkToCheck != null && linkToCheck.length < 1
                                      ? AppLocalizations.of(context)!.empty_link
                                      : null,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(15),
                                  hintText: "https://....",
                                  isDense: true,
                                  filled: true,
                                  icon: FaIcon(FontAwesomeIcons.link),
                                  prefixIconColor: Colors.black38,
                                  hoverColor: Color(0xffF5F5F6),
                                  focusColor: Color(0xffF5F5F6),
                                  hintStyle: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w400),
                                  fillColor: Color.fromARGB(255, 241, 241, 254),
                                  //Colors.white,
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(15))),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              AppLocalizations.of(context)!.categories,
                              style: GoogleFonts.poppins(
                                  fontSize: 19, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 17,
                            ),
                            Container(
                              margin: EdgeInsets.all(0.0),
                              height: 100,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    StreamBuilder(
                                        stream:
                                            CategoryStream, //build connection
                                        builder: (context,
                                            AsyncSnapshot<QuerySnapshot>
                                                streamSnapshot) {
                                          if (streamSnapshot.hasData) {
                                            return ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              shrinkWrap: true,
                                              itemCount: streamSnapshot.data!
                                                  .docs.length, //number of rows
                                              itemBuilder: (context, index) {
                                                final DocumentSnapshot
                                                    documentSnapshot =
                                                    streamSnapshot
                                                        .data!.docs[index];
                                                return CategoryItemForCreate(
                                                    name: documentSnapshot[
                                                        "name"],
                                                    intIconToUse: icons[
                                                        documentSnapshot[
                                                            "icon"]]);
                                              },
                                            );
                                          } else {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                        }),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(),
                            SizedBox(
                                width: double.infinity,
                                height: 38,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final isValidForm =
                                        formKey.currentState!.validate();
                                    if (isValidForm) {
                                      goToCreate(
                                          categories, title, url, isPrivate);
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.create,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Color.fromARGB(255, 0, 101, 255)),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13))),
                                      shadowColor: MaterialStateProperty.all(
                                          Colors.transparent)),
                                )),
                          ]),
                    )));
          });
        });
  }

  Future<void> _createLinkTabDirectShare(String? link) async {
    DataManager.instance.setDataIntent("");
    _createLinkTab(link);
  }

  Future<String> _getUrl(String url) async {
    try {
      Favicon? iconUrl = await FaviconFinder.getBest(url);
      String? x = iconUrl?.url;
      print("Ok va benino");

      if (x != null) {
        return x;
      } else {
        return _getUrl("https://pecillizanini.me");
      }
    } catch (e) {
      return _getUrl("https://pecillizanini.me");
    }
  }

  showTerms() async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              height: MediaQuery.of(ctx).viewInsets.bottom + 400,
              child: Padding(
                padding:
                    EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 0),
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.terms,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, color: Colors.black)),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: IconButton(
                          onPressed: () async {
                            try {
                              launchUrl(Uri.parse(
                                  "https://sites.google.com/view/terms-conditions-linx/"));
                            } catch (e) {
                              print("Errore" + e.toString());
                            }
                          },
                          icon: Icon(
                            FeatherIcons.info,
                            color: Colors.black54,
                          )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "ok",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(255, 0, 101, 255)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13))),
                          shadowColor:
                              MaterialStateProperty.all(Colors.transparent)),
                    ),
                  ],
                ),
              ));
        });
  }

  Future<void> _createCategoryTab([DocumentSnapshot? documentSnapshot]) async {
    final title = TextEditingController();
    List<String> allCat = <String>[];

    var CategoryStream = FirebaseFirestore.instance
        .collection("categories")
        .where("idUser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              height: MediaQuery.of(ctx).viewInsets.bottom + 400,
              child: Padding(
                  padding:
                      EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 0),
                  child: Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.create_categories,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 0, 70, 175))),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            AppLocalizations.of(context)!.title,
                            style: GoogleFonts.poppins(
                                fontSize: 19, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: title,
                            validator: (titleToCheck) =>
                                titleToCheck != null && titleToCheck.length < 1
                                    ? AppLocalizations.of(context)!.empty_title
                                    : null,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                hintText: AppLocalizations.of(context)!.title,
                                isDense: true,
                                filled: true,
                                icon: FaIcon(FontAwesomeIcons.pen),
                                prefixIconColor: Colors.black38,
                                hoverColor: Color(0xffF5F5F6),
                                focusColor: Color(0xffF5F5F6),
                                hintStyle: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black45,
                                    fontWeight: FontWeight.w400),
                                fillColor: Color.fromARGB(255, 241, 241, 254),
                                //Colors.white,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(15))),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(),
                          Text(
                            "Icon",
                            style: GoogleFonts.poppins(
                                fontSize: 19, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: ToggleButton(),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                              width: double.infinity,
                              height: 38,
                              child: ElevatedButton(
                                onPressed: () async {
                                  print(DataManager.instance.IconToUse);
                                  final isValidForm =
                                      formKey.currentState!.validate();
                                  if (isValidForm) {
                                    if (!allCat.contains(title.text) &&
                                        DataManager.instance.IconToUse
                                            .toString()
                                            .isNotEmpty) {
                                      await _createCategories(
                                          name: title.text,
                                          icon: DataManager.instance.IconToUse,
                                          idUser: idUser,
                                          caseSearchList:
                                              setSearchParam(title.text));
                                    }
                                  }
                                },
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .create_categories,
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
                        ]),
                  )));
        });
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
    } else {
      await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext ctx) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter state) {
              return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  height: MediaQuery.of(ctx).viewInsets.bottom + 300,
                  child: Padding(
                      padding: EdgeInsets.only(
                          top: 25, left: 25, right: 25, bottom: 0),
                      child: Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          key: formKey,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.login,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 25,
                                        color:
                                            Color.fromARGB(255, 0, 70, 175))),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(AppLocalizations.of(context)!.password,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 25,
                                        color:
                                            Color.fromARGB(255, 0, 70, 175))),
                                TextFormField(
                                    validator: (psswd) => psswd != null &&
                                            !EmailValidator.validate(psswd) &&
                                            psswd.length < 5
                                        ? AppLocalizations.of(context)!
                                            .valid_password
                                        : null,
                                    controller: psswdController,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.lock_rounded),
                                        hintText: AppLocalizations.of(context)!
                                            .password)),
                                SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final isValidForm =
                                        formKey.currentState!.validate();
                                    if (isValidForm) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PrivatePage()),
                                      );
                                    }
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.login,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Color.fromARGB(255, 0, 101, 255)),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13))),
                                      shadowColor: MaterialStateProperty.all(
                                          Colors.transparent)),
                                ),
                              ]))));
            });
          });
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

  goToCreate(var categories, var title, var url, var isPrivate) async {
    categories = DataManager.instance.categoriesToUse;
    if (isPrivate == null) {
      isPrivate = false;
    }
    print("Prima");
    String x = await _getUrl(checkLink(url.text));
    x = await checkIsIco(x);
    //if (!x.endsWith(".png") && !x.endsWith(".ico")) {
    //return await _getUrl("https://pecillizanini.me");
    //}
    print("Dopo");
    String caseNumber = title.text.toString();
    print("Stringa = a " + x);
    _createLink(
        title: title.text,
        url: checkLink(url.text),
        isPrivate: isPrivate,
        idUser: idUser,
        caseSearchList: setSearchParam(caseNumber),
        categories: categories,
        urlPNG: x);

    title.text = '';
    url.text = '';

    DataManager.instance.categoriesToUse = <String>[];
  }

  Future<String> checkIsIco(String x) async {
    if (x.endsWith(".png") || x.endsWith(".ico")) {
      print("LINK: " + x);
      return x;
    } else {
      return _getUrl("http://www.google.com/favicon.ico");
    }
  }

  String? checkInput(String string) {
    if (string.isEmpty || string.length < 2) {
      return "This can't be empty";
    }
    return null;
  }
}
