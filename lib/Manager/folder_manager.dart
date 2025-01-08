import 'package:linxflutter/Manager/category_manager.dart';
import 'package:linxflutter/Manager/link_manager.dart';

class FolderManager {
  FolderManager._privateConstructor();

  static final FolderManager _instance = FolderManager._privateConstructor();

  static FolderManager get instance => _instance;
}

class Folder {
  late String title;
  late String idFounder;
  late bool? isPrivate = false;
  late List<String>? idUsers;
  late List<String> caseSearchList;
  late List<Link>? links;
  late List<Category>? categories;

  Folder(
      {required this.title,
      required this.idFounder,
      required this.isPrivate,
      required this.links,
      required this.caseSearchList,
      required this.categories,
      required this.idUsers,
      });

  Map<String, dynamic> toJson() => {
        'title': title,
        'idFounder': idFounder,
        'isPrivate': isPrivate,
        'links': links,
        'idUsers': idUsers,
        'caseSearchList': caseSearchList,
        'categories': categories,
      };

  static Folder fromJson(Map<String, dynamic> json) => Folder(
        title: json['title'],
        idFounder: json['idFounder'],
        isPrivate: json['isPrivate'],
        links: json['links'],
        idUsers: json['idUsers'],
        caseSearchList: json['caseSearchList'],
        categories: json['categories'],
      );
}
