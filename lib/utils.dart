import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'base_model.dart';

Directory docsDir;

Future selectDate(BuildContext inContext, BaseModel inModel, String inDateString) async {
  print("## globals.selectDate()");

  DateTime initialDate = DateTime.now();

  if (inDateString != null) {
    List dateParts = inDateString.split(",");
    initialDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
  }

  ///显示日历控件，显示当前时间
  DateTime picked = await showDatePicker(
    context: inContext,
    initialDate: initialDate,
    firstDate: DateTime(1900),
    lastDate: DateTime(100),
  );

  ///有时间要学习一下intl 包，用于国际化及日期格式，数字格式化
  ///setChosenDate会触发更新
  if (picked != null) {
    inModel.setChosenDate(DateFormat.yMMMd("en_US").format(picked.toLocal()));
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
