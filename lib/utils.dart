import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'base_model.dart';
import 'i18n.dart';

Directory docsDir;

Future selectDate(BuildContext context, BaseModel model, String dateString) async {
  print("## globals.selectDate()");

  DateTime initialDate = DateTime.now();

  if (dateString != null) {
    List dateParts = dateString.split(",").map((e) => int.parse(e)).toList();
    initialDate = DateTime(dateParts[0], dateParts[1], dateParts[2]);
  }

  ///显示日历控件，显示当前时间
  DateTime picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
  );

  ///有时间要学习一下intl 包，用于国际化及日期格式，数字格式化
  ///setChosenDate会触发更新
  if (picked != null) {
    model.setChosenDate(DateFormat.yMMMd(I18n.curLang(context)).format(picked.toLocal()));
    return "${picked.year},${picked.month},${picked.day}";
  }
}

///["red","green", "blue", "yellow", "grey", "purple"]
Color colorByStr(String inColor) {
  Color color;
  switch (inColor) {
    case "red":
      color = Colors.red;
      break;
    case "green":
      color = Colors.green;
      break;
    case "blue":
      color = Colors.blue;
      break;
    case "yellow":
      color = Colors.yellow;
      break;
    case "grey":
      color = Colors.grey;
      break;
    case "purple":
      color = Colors.purple;
      break;
    default:
      color = Colors.white;
      break;
  }
  return color;
}
