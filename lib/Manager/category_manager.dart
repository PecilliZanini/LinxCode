import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryManager {

  CategoryManager._privateConstructor();

  static final CategoryManager _instance = CategoryManager._privateConstructor();

  static CategoryManager get instance => _instance;

}

class Category{
  late String idCategory;
  late String name;
  late int? icon;
  late String idUser;
  late List<dynamic> caseSearchList;


  Category({
    required this.idCategory,
    required this.name,
    this.icon,
    //required this.icon,
    required this.idUser,
    required this.caseSearchList,});

  Map<String, dynamic> toJson() => {
    'idCategory' : idCategory,
    'name' : name,
    'icon' : icon,
    'idUser' : idUser,
    'caseSearchList' : caseSearchList,

  };

  static Category fromJson(Map<String, dynamic> json) => Category(
    idCategory: json['idCategory'],
    name: json['name'],
    icon: json['icon'],
    idUser: json['idUser'],
    caseSearchList: json['caseSearchList'],
  );

}