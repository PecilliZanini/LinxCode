import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linxflutter/Manager/category_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:favicon/favicon.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../Manager/data_manager.dart';
import 'categoryItemForCreate.dart';

class LinkItem extends StatefulWidget {
  final String title;
  final String url;
  final String urlPNG;
  DocumentSnapshot documentSnapshot;
  String titleToCheck = "";
  String linkToCheck = "";
  List<Icon> icons = [
    Icon(FeatherIcons.book),
    Icon(FeatherIcons.tv),
    Icon(FeatherIcons.code),
    Icon(FeatherIcons.compass),
    Icon(FeatherIcons.play),
    Icon(FeatherIcons.activity),
  ];

  final formKey = GlobalKey<FormState>();

  LinkItem(
      {super.key,
      required this.title,
      required this.url,
      required this.urlPNG,
      required this.documentSnapshot});

  @override
  State<LinkItem> createState() => _LinkItemState();
}

class _LinkItemState extends State<LinkItem> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color.fromARGB(255, 248, 250, 247),
          ),
          height: 90,
          child: GestureDetector(
            onTap: () => _launchUrl(Uri.parse(widget.url)),
            onLongPress: () {
              _update(widget.documentSnapshot);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Image.network(widget.urlPNG, height: 40),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                  SizedBox(
                    width: 17,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        titleToShow(),
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700, fontSize: 20),
                      ),
                      Text(
                        linkToShow(),
                        style: GoogleFonts.poppins(),
                      )
                    ],
                  ),
                  Spacer(),
                  IconButton(
                      onPressed: () {
                        share(widget.title, widget.linkToCheck, widget.url,
                            widget.title);
                      },
                      icon: Icon(
                        Icons.share,
                        color: Colors.blue[800],
                      )),
                  IconButton(
                      onPressed: () {
                        _launchUrl(Uri.parse(widget.url));
                      },
                      icon: Icon(
                        FeatherIcons.arrowRightCircle,
                        color: Colors.blue[800],
                      ))
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  String linkToShow() {
    var x =
        widget.url.replaceAll("https://www.", "").replaceAll("http://www.", "");
    if (x.length > 14) {
      x = x.substring(0, 15) + "...";
      return x;
    } else {
      return x;
    }
  }

  String titleToShow() {
    String x = widget.title;
    if (x.length > 10) {
      x = x.substring(0, 7) + "...";
      ;
      return x;
    } else {
      return x;
    }
  }

  Future<String?> _getUrl(String url) async {
    Favicon? iconUrl = await FaviconFinder.getBest(url);
    return iconUrl?.url;
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    final title = TextEditingController();
    final url = TextEditingController();
    DataManager.instance.categoriesToUse = <String>[];
    List<Icon> icons = [
      Icon(FeatherIcons.book),
      Icon(FeatherIcons.tv),
      Icon(FeatherIcons.code),
      Icon(FeatherIcons.compass),
      Icon(FeatherIcons.play),
      Icon(FeatherIcons.activity),
    ];

    for (String y in documentSnapshot!['categories']) {
      if (DataManager.instance.categoriesToUse.contains(y)) {
        DataManager.instance.categoriesToUse.remove(y);
      } else if (DataManager.instance.categoriesToUse.length < 3) {
        DataManager.instance.categoriesToUse.add(y);
        print(DataManager.instance.categoriesToUse.length);
      }
    }

    title.text = documentSnapshot['title'].toString();
    url.text = documentSnapshot['link'].toString();

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
            height: MediaQuery.of(ctx).viewInsets.bottom + 850,
            child: SingleChildScrollView(
              child: Padding(
                  padding:
                      EdgeInsets.only(top: 45, left: 25, right: 25, bottom: 25),
                  child: Form(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.update,
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
                                labelText: documentSnapshot["title"],
                                filled: true,
                                icon: FaIcon(FontAwesomeIcons.heading),
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
                                hintText: "http://....",
                                isDense: true,
                                filled: true,
                                labelText: documentSnapshot["link"],
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
                            height: 20,
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
                                              DataManager.instance.categories
                                                  .add(Category(
                                                      //icon: documentSnapshot[
                                                      //"icon"],
                                                      idCategory:
                                                          documentSnapshot[
                                                              "idCategory"],
                                                      name: documentSnapshot[
                                                          "name"],
                                                      idUser: documentSnapshot[
                                                          "idUser"],
                                                      caseSearchList:
                                                          documentSnapshot[
                                                              "caseSearchList"]));
                                              return CategoryItemForCreate(
                                                  name:
                                                      documentSnapshot["name"],
                                                  intIconToUse: icons[
                                                      documentSnapshot[
                                                          "icon"]]);
                                            },
                                          );
                                        } else {
                                          return const Center(
                                            child: CircularProgressIndicator(),
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
                          Row(
                            children: [
                              // ElevatedButton(
                              //     onPressed: () async {
                              //       _deleteLink(documentSnapshot.id);
                              //     },
                              //     child: Text(
                              //       AppLocalizations.of(context)!.delete,
                              //       style: GoogleFonts.poppins(
                              //           fontWeight: FontWeight.w600,
                              //           color: Colors.white),
                              //     ),
                              //     style: ButtonStyle(
                              //         backgroundColor:
                              //             MaterialStateProperty.all(
                              //                 Color.fromARGB(255, 0, 101, 255)),
                              //         shape: MaterialStateProperty.all(
                              //             RoundedRectangleBorder(
                              //                 borderRadius:
                              //                     BorderRadius.circular(13))),
                              //         shadowColor: MaterialStateProperty.all(
                              //             Colors.transparent))),
                              // Icon(
                              //   Icons.delete,
                              //   color: Color.fromARGB(255, 198, 39, 39),
                              // ),
                              // SizedBox(
                              //   width: 45,
                              //   height: 20,
                              // ),
                              // ElevatedButton(
                              //     onPressed: () async {
                              //       share(widget.title, widget.linkToCheck,
                              //           widget.url, widget.title);
                              //     },
                              //     child: Text(
                              //       AppLocalizations.of(context)!.share,
                              //       style: GoogleFonts.poppins(
                              //           fontWeight: FontWeight.w600,
                              //           color: Colors.white),
                              //     ),
                              //     style: ButtonStyle(
                              //         backgroundColor:
                              //             MaterialStateProperty.all(
                              //                 Color.fromARGB(255, 0, 101, 255)),
                              //         shape: MaterialStateProperty.all(
                              //             RoundedRectangleBorder(
                              //                 borderRadius:
                              //                     BorderRadius.circular(13))),
                              //         shadowColor: MaterialStateProperty.all(
                              //             Colors.transparent))),
                              // Icon(
                              //   Icons.share,
                              //   color: Color.fromARGB(137, 0, 0, 0),
                              // ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                              width: double.infinity,
                              height: 38,
                              child: ElevatedButton(
                                onPressed: () async {
                                  var stream = FirebaseFirestore.instance
                                      .collection("links");

                                  await stream.doc(documentSnapshot.id).update({
                                    "title": title.text.toString(),
                                    "link": checkLink(url.text.toString()),
                                    "isPrivate": documentSnapshot["isPrivate"],
                                    "caseSearchList":
                                        setSearchParam(title.text.toString()),
                                    "categories":
                                        DataManager.instance.categoriesToUse
                                  });
                                  Navigator.of(context).pop();
                                  DataManager.instance.categoriesToUse =
                                      <String>[];
                                  title.text = '';
                                  url.text = '';
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.update,
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
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                              width: double.infinity,
                              height: 38,
                              child: OutlinedButton(
                                onPressed: () async {
                                  _deleteLink(documentSnapshot.id);
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.delete,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                                style: ButtonStyle(
                                    side: MaterialStateProperty.resolveWith<
                                        BorderSide>((_) {
                                      return BorderSide(
                                          color: Color.fromARGB(
                                              255, 255, 131, 122),
                                          width: 2.5);
                                    }),
                                    backgroundColor: MaterialStateProperty.all(
                                        Color.fromARGB(255, 255, 149, 149)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13))),
                                    shadowColor: MaterialStateProperty.all(
                                        Colors.transparent)),
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                              width: double.infinity,
                              height: 38,
                              child: OutlinedButton(
                                onPressed: () async {
                                  changePrivacy(documentSnapshot);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.is_private,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                                style: ButtonStyle(
                                    side: MaterialStateProperty.resolveWith<
                                        BorderSide>((_) {
                                      return BorderSide(
                                          color: Color.fromARGB(58, 0, 255, 64),
                                          width: 2.5);
                                    }),
                                    backgroundColor: MaterialStateProperty.all(
                                        Color.fromARGB(255, 60, 194, 71)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13))),
                                    shadowColor: MaterialStateProperty.all(
                                        Colors.transparent)),
                              )),
                        ]),
                  )),
            ),
          );
        });
  }

  String checkLink(String url) {
    print("Url:" + url);
    if (!url.startsWith("https://www.") && !url.startsWith("http://www.")) {
      return "http://www." + url;
    }

    return url;
  }

  changePrivacy(var documentSnapshot) async {
    var stream = FirebaseFirestore.instance.collection("links");

    final data = documentSnapshot.data();

    print("data" + data.toString());
    print("Dataaaaaaaa");
    print((data?['isPrivate']));

    var k = data?['isPrivate'];
    if (k) {
      k = false;
    } else {
      k = true;
    }
    Navigator.of(context).pop();
    await stream.doc(documentSnapshot.id).update({
      "isPrivate": k,
    });
  }

  Future<void> share(
      String title, String text, String linkUrl, String chooserTitle) async {
    await FlutterShare.share(
        title: title,
        text: AppLocalizations.of(context)!.usedlinxto +
            title +
            ": " +
            linkUrl +
            "\n" +
            AppLocalizations.of(context)!.downloadlinxon,
        chooserTitle: chooserTitle);
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

  _deleteLink(String linkID) async {
    var stream = FirebaseFirestore.instance.collection("links");

    await stream.doc(linkID).delete();
  }
}
