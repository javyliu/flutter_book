import 'package:flutter/material.dart';
import 'package:flutter_book/appointments/appointment_entry.dart';
import 'package:flutter_book/appointments/appointments_list.dart';
import 'package:flutter_book/appointments/models/appointment.dart';
import 'package:provider/provider.dart';

class Appointments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppointmentModel>(
      create: (context) {
        var am = AppointmentModel();
        am.loadData("appointments");
        return am;
      },
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
