import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linxflutter/Manager/data_manager.dart';
import 'package:linxflutter/Manager/event_manager.dart';
import 'package:linxflutter/home.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:linxflutter/pageFiltered.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Manager/event_listener.dart';
import '../settings.dart';

class CategoryItemForHome extends StatefulWidget implements resetFilter {
  final String title;
  Color? bgColor;
  var borderColor;
  var intIconToUse;
  DocumentSnapshot id;

  //var selectedIcon;

  CategoryItemForHome({
    super.key,
    required this.title,
    required this.intIconToUse,
    required this.id,
    //, required selectedIcon
  });
  @override
  State<CategoryItemForHome> createState() => _CategoryItemForHome();

  @override
  void reset() {}
}

class _CategoryItemForHome extends State<CategoryItemForHome> {
  Color? bgColor = Colors.white;
  Color borderColor = Colors.black12;
  Icon selectedIcon = Icon(
    FeatherIcons.chrome,
  );

  bool isFetching = false;
  List<String> dataList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          selectedIcon = widget.intIconToUse;
          print(
              "Il numero che metto qui corrisponde a: " + widget.intIconToUse);

          bgColor = Colors.white;
          borderColor = Colors.black12;
        }));
  }

  bool isSelected = false;
  var LinkStream;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
          child: Container(

              /*decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color.fromARGB(255, 248, 250, 247),
          ),*/
              height: 100,
              width: 90,
              child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => {},
                    onLongPress: () => _deleteCat(widget.id),
                    child: Column(
                      children: [
                        Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(color: borderColor),
                                color: bgColor,
                                borderRadius: BorderRadius.circular(12)),
                            child: IconButton(
                                iconSize: 30,
                                icon: widget.intIconToUse,
                                onPressed: () {
                                  // DataManager.instance.categoryFilter =
                                  //     widget.title;

                                  //EventManager.instance.resetList();

                                  setState(() {
                                    if (!isSelected) {
                                      DataManager.instance.categoryFilter =
                                          widget.title;
                                      {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PageFilter()),
                                        );
                                      }
                                    } else {
                                      bgColor = Colors.white;
                                      borderColor = Colors.black12;
                                      selectedIcon = Icon(
                                        FeatherIcons.chrome,
                                        color: Colors.black54,
                                      );
                                      DataManager.instance.categoryFilter = "";
                                      isSelected = false;
                                    }
                                    print(
                                        "!!!!!!!!!!!!!-------------- ${DataManager.instance.categoryFilter}");
                                  });
                                })),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          catToShow(),
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ],
                    ),
                  )))),
    ]);
  }

  String catToShow() {
    String x = widget.title;
    if (x.length > 10) {
      x = x.substring(0, 7) + "...";
      return x;
    } else {
      return x;
    }
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _deleteCat(DocumentSnapshot documentSnapshot) async {
    var LinkStream;
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
              height: MediaQuery.of(ctx).viewInsets.bottom + 150,
              child: Padding(
                  padding:
                      EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 0),
                  child: Column(children: [
                    Text(
                      (AppLocalizations.of(context)!.delete) + "?",
                      style: GoogleFonts.poppins(
                          fontSize: 19, fontWeight: FontWeight.w500),
                    ),
                    Center(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                          ),
                          ElevatedButton(
                            onPressed: () async {},
                            child: IconButton(
                                iconSize: 30,
                                icon: Icon(FeatherIcons.check),
                                onPressed: () async {
                                  _deleteCategories(documentSnapshot.id);
                                  Navigator.of(context).pop();
                                }),
                          ),
                          SizedBox(width: 80),
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {},
                              child: IconButton(
                                  iconSize: 30,
                                  icon: Icon(Icons.cancel),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }),
                            ),
                          )
                        ],
                      ),
                    ),
                  ])));
        });
  }

  Future<void> _deleteCategories(String catID) async {
    var stream = await FirebaseFirestore.instance.collection("categories");

    var LinkStream = await FirebaseFirestore.instance
        .collection("links")
        .where("idUser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where("isPrivate", isEqualTo: false)
        .where("caseSearchList", arrayContains: catID);

    await stream.doc(catID).delete();
  }
}
