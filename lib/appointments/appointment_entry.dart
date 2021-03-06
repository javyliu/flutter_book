import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_book/appointments/appointment_db_worker.dart';

import '../utils.dart' as utils;
import 'models/appointment.dart';

class AppointmentEntry extends StatelessWidget {
  final TextEditingController _titleCon = TextEditingController();
  final TextEditingController _desCon = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    log("--- appointment entry build");

    var appointmentModel = Provider.of<AppointmentModel>(context, listen: false);
    _titleCon.addListener(() {
      appointmentModel.entityBeingEdited.title = _titleCon.text;
    });
    _desCon.addListener(() {
      appointmentModel.entityBeingEdited.description = _desCon.text;
    });
    if (appointmentModel.entityBeingEdited != null) {
      _titleCon.text = appointmentModel.entityBeingEdited.title;
      _desCon.text = appointmentModel.entityBeingEdited.description;
    }

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 10,
        ),
        child: Row(
          children: [
            FlatButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  appointmentModel.setStackIndex(0);
                },
                child: Text('Cancel')),
            Spacer(),
            FlatButton(onPressed: () => _save(context, appointmentModel), child: Text('Save')),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.subject),
              title: TextFormField(
                decoration: InputDecoration(hintText: "Title"),
                controller: _titleCon,
                validator: (value) {
                  if (value.isEmpty) return "Please enter a title";
                  return null;
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                decoration: InputDecoration(hintText: "Description"),
                controller: _desCon,
              ),
            ),
            ListTile(
              leading: Icon(Icons.today),
              title: Text("Date"),
              subtitle: Text(appointmentModel.chosenDate ?? ""),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                color: Colors.blue,
                onPressed: () async {
                  String chosenDate = await utils.selectDate(context, appointmentModel, appointmentModel.entityBeingEdited.apptDate);
                  if (chosenDate != null) {
                    appointmentModel.entityBeingEdited.apptDate = chosenDate;
                  }
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.alarm),
              title: Text('Time'),
              subtitle: Text(appointmentModel.apptTime ?? ""),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                color: Colors.blue,
                onPressed: () => _selectTime(context, appointmentModel),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, AppointmentModel model) async {
    if (!_formKey.currentState.validate()) return;
    if (model.entityBeingEdited.id == null) {
      await AppointmentDBWorker.db.create(model.entityBeingEdited);
    } else {
      await AppointmentDBWorker.db.update(model.entityBeingEdited);
    }

    model.loadData("appointments");
    model.setStackIndex(0);
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      content: Text('Appointment Saved'),
    ));
  }
}

Future _selectTime(BuildContext context, AppointmentModel am) async {
  TimeOfDay initTime = TimeOfDay.now();
  Appointment apt = am.entityBeingEdited;
  if (apt.apptTime != null) {
    List _stime = apt.apptTime.split(",").map((e) => int.parse(e)).toList();
    initTime = TimeOfDay(hour: _stime[0], minute: _stime[1]);
  }

  TimeOfDay picked = await showTimePicker(
    context: context,
    initialTime: initTime,
    builder: (context, child) {
      return Localizations(
        locale: Locale(Intl.getCurrentLocale()),
        delegates: <LocalizationsDelegate>[GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
        child: child,
      );
    },
  );

  if (picked != null) {
    apt.apptTime = "${picked.hour},${picked.minute}";
    am.setApptTime(picked.format(context));
  }
}
