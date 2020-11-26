import 'dart:developer';

import 'package:flutter/material.dart';

class BaseModel extends ChangeNotifier {
  int stackIndex = 0;
  List entityList = [];

  var entityBeingEdited;

  dynamic dbWorker;

  String chosenDate;

  void setChosenDate(String inDate) {
    print("## BaseModel.setChosenDate(): inDate = $inDate");

    chosenDate = inDate;
    notifyListeners();
  }

  void loadData(String inEntityType) async {
    log("---## ${inEntityType}Model.loadData()");
    entityList = await dbWorker.all();

    notifyListeners();
  }

  void setStackIndex(int inStackIndex) {
    print("## BaseModel.setStackIndex(): inStackIndex = $inStackIndex");
    stackIndex = inStackIndex;
    notifyListeners();
  }
}
