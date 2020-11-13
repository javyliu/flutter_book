import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
class I18n {
  static String t(BuildContext context, String key) {
    return FlutterI18n.translate(context, key);
  }
}
