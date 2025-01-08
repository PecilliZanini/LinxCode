import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linxflutter/Manager/data_manager.dart';
import 'package:linxflutter/Manager/event_manager.dart';
import 'package:linxflutter/home.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:linxflutter/Manager/category_manager.dart';

import '../Manager/event_listener.dart';

class CategoryItemForCreate extends StatefulWidget {
  final String name;
  Color? bgColor;
  var borderColor;
  var intIconToUse;

  CategoryItemForCreate({
    super.key,
    required this.name,
    this.intIconToUse,
  });
  @override
  State<CategoryItemForCreate> createState() => _CategoryItemForCreate();
}

class _CategoryItemForCreate extends State<CategoryItemForCreate> {
  Color? bgColor = Colors.white;
  Color borderColor = Colors.black12;
  Icon selectedIcon = Icon(
    FeatherIcons.chrome,
    color: Colors.black54,
  );

  @override
  void reset() {}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          selectedIcon = widget.intIconToUse;
          if (DataManager.instance.categoriesToUse.contains(widget.name)) {
            bgColor = Color.fromARGB(58, 0, 255, 64);
            borderColor = Colors.transparent;
            selectedIcon = widget.intIconToUse;
          } else {
            bgColor = Colors.white;
            borderColor = Colors.black12;
            selectedIcon = widget.intIconToUse;
          }
        }));
  }

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
                            icon: selectedIcon,
                            onPressed: () {
                              DataManager.instance.addCat(widget.name);
                              setState(() {
                                if (DataManager.instance.categoriesToUse
                                    .contains(widget.name)) {
                                  bgColor = Color.fromARGB(58, 0, 255, 64);
                                  borderColor = Colors.transparent;
                                  selectedIcon = Icon(FeatherIcons.check);
                                } else {
                                  bgColor = Colors.white;
                                  borderColor = Colors.black12;
                                  selectedIcon = widget.intIconToUse;
                                }
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
              ))),
    ]);
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  String catToShow() {
    String x = widget.name;
    if (x.length > 10) {
      x = x.substring(0, 7) + "...";
      ;
      return x;
    } else {
      return x;
    }
  }

  show() {
    bgColor = Color.fromARGB(58, 0, 255, 64);
    borderColor = Colors.transparent;
    selectedIcon = Icon(FeatherIcons.check);
  }

  hide() {
    bgColor = Colors.white;
    borderColor = Colors.black12;
    selectedIcon = Icon(
      FeatherIcons.chrome,
      color: Colors.black54,
    );
  }
}
