import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'appointment_entry.dart';
import 'appointments_list.dart';
import 'models/appointment.dart';

class Appointments extends StatelessWidget {
  Appointments() {
    model.loadData("appointments");
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: model,
      child: BuildIndexedStack(),
    );
  }
}

class BuildIndexedStack extends StatelessWidget {
  const BuildIndexedStack({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log("--- appointments build");

    var idx = context.select<AppointmentModel, int>((model) => model.stackIndex);

    return IndexedStack(
      index: idx,
      children: [
        AppointmentsList(),
        AppointmentEntry(),
      ],
    );
  }
}
