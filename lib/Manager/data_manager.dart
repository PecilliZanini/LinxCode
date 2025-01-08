import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:linxflutter/Manager/category_manager.dart';
import 'package:linxflutter/Manager/link_manager.dart';

class DataManager {
  String? _dataIntent = "";
  List<String> categoriesToUse = <String>[];
  int IconToUse = 0;
  

  bool? showHome;

  DataManager._privateConstructor();

  static final DataManager _instance = DataManager._privateConstructor();

  static DataManager get instance => _instance;

  List<Link> publicLink = <Link>[];
  List<Link> privateLink = <Link>[];
  List<Link> allLink = <Link>[];
  List<Category> categories = <Category>[];

  void fullList() {
    allLink.addAll(publicLink);
    allLink.addAll(privateLink);
  }

  String categoryFilter = "";

  String? getDataIntent() {
    return _dataIntent;
  }

  void setDataIntent(String? value) {
    _dataIntent = value;
  }

  void addCat(String name) {
    if (categoriesToUse.contains(name)) {
      categoriesToUse.remove(name);
    } else {
      categoriesToUse.add(name);
    }
    return;
  }
}
