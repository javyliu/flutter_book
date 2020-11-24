import 'dart:convert';

import 'package:flutter_book/appointments/appointment_db_worker.dart';

import '../../base_model.dart';

class Appointment {
  int id;
  String title;
  String description;
  String apptDate;
  String apptTime;

  Appointment({this.id, this.title, this.description, this.apptDate, this.apptTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'apptDate': apptDate,
      'apptTime': apptTime,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Appointment(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      apptDate: map['apptDate'],
      apptTime: map['apptTime'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Appointment.fromJson(String source) => Appointment.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Appointment(id: $id, title: $title, description: $description, apptDate: $apptDate, apptTime: $apptTime)';
  }
}

class AppointmentModel extends BaseModel {
  String apptTime;
  AppointmentModel() {
    dbWorker = AppointmentDBWorker.db;
  }

  void setApptTime(String stime) {
    apptTime = stime;
    notifyListeners();
  }
}
