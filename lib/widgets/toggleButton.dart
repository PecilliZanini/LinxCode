import 'package:favicon/favicon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:linxflutter/Manager/data_manager.dart';

class ToggleButton extends StatefulWidget {
  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  List<bool> isSelected = [true, false, false, false, false, false];

  @override
  Widget build(BuildContext context) => ToggleButtons(
        isSelected: isSelected,
        children: <Widget>[
          Icon(FeatherIcons.book),
          Icon(FeatherIcons.tv),
          Icon(FeatherIcons.code),
          Icon(FeatherIcons.compass),
          Icon(FeatherIcons.play),
          Icon(FeatherIcons.activity),
        ],
        onPressed: (int newIndex) {
          setState(() {
            for (int i = 0; i < isSelected.length; i++) {
              if (i == newIndex) {
                isSelected[i] = true;
                DataManager.instance.IconToUse = i;
                print("Sto stampando: " +
                    DataManager.instance.IconToUse.toString());
              } else {
                isSelected[i] = false;
              }
            }
          });
        },
      );

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
}
