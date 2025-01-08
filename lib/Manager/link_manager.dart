import 'package:linxflutter/Manager/category_manager.dart';

class LinkManager {
  LinkManager._privateConstructor();

  static final LinkManager _instance = LinkManager._privateConstructor();

  static LinkManager get instance => _instance;
}

class Link {
  late String title;
  late String link;
  late bool? isPrivate = false;
  late String idUser;
  late String idLink;
  late String urlPNG;
  late List<dynamic> caseSearchList;
  late List<dynamic> categories = <dynamic>[];

  Link({
    required this.title,
    required this.link,
    required this.isPrivate,
    required this.idUser,
    required this.idLink,
    required this.urlPNG,
    required this.caseSearchList,
    required this.categories,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'link': link,
        'isPrivate': isPrivate,
        'urlPNG': urlPNG,
        'idUser': idUser,
        'idLink': idLink,
        'caseSearchList': caseSearchList,
        'categories': categories,
      };

  static Link fromJson(Map<String, dynamic> json) => Link(
        title: json['title'],
        link: json['link'],
        isPrivate: json['isPrivate'],
        idUser: json['idUser'],
        idLink: json['idLink'],
        urlPNG: json['urlPNG'],
        caseSearchList: json['caseSearchList'],
        categories: json['categories'],
      );
}
