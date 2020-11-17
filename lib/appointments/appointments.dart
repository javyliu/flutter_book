import 'package:flutter/material.dart';
import 'package:flutter_book/appointments/appointment_entry.dart';
import 'package:flutter_book/appointments/appointments_list.dart';
import 'package:flutter_book/appointments/models/appointment.dart';
import 'package:scoped_model/scoped_model.dart';

import 'appointment_db_worker.dart';

class Appointments extends StatelessWidget {

  Appointments(){
    appointmentModel.loadData("appointments", AppointmentDBWorker.db);
    
  }


  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppointmentModel>(
      model: appointmentModel,
      child: ScopedModelDescendant<AppointmentModel>(
        builder: (ctx, child, model) {
          return IndexedStack(
            index: model.stackIndex,
            children: [
              AppointmentsList(),
              AppointmentEntry(),
              
            ],
          );
        },
      ),
    );
  }
}