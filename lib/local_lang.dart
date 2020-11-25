import 'package:flutter/foundation.dart';

class LocalLang extends ChangeNotifier {
  var _lang;
  set lang(value) {
    _lang = value;
    notifyListeners();
  }

  String get curLang => _lang;
}
