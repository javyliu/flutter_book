import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import '../i18n.dart';
import 'appointment_db_worker.dart';
import 'models/appointment.dart';

class AppointmentsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    EventList<Event> _markedDateMap = EventList();

    for (Appointment item in appointmentModel.entityList) {
      List dateParts = item.apptDate.split(",");
      DateTime aptDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
      _markedDateMap.add(
        aptDate,
        Event(
          date: aptDate,
          icon: Container(
            decoration: BoxDecoration(color: Colors.blue),
          ),
        ),
      );
    }

    return ScopedModel<AppointmentModel>(
      model: appointmentModel,
      child: ScopedModelDescendant<AppointmentModel>(
        builder: (ctx, child, model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                appointmentModel.entityBeingEdited = Appointment();
                Appointment _edited = appointmentModel.entityBeingEdited;
                DateTime now = DateTime.now();
                _edited.apptDate = "${now.year}, ${now.month},${now.day}";
                appointmentModel.setChosenDate(DateFormat.yMMMMd("en_US").format(now.toLocal()));
                appointmentModel.setApptTime(null);
                appointmentModel.setStackIndex(1);
              },
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 10,
                    ),
                    child: CalendarCarousel<Event>(
                      locale: I18n.curLang(ctx),
                      thisMonthDayBorderColor: Colors.grey,
                      daysHaveCircularBorder: true,
                      markedDatesMap: _markedDateMap,
                      onDayPressed: (DateTime inDate, List<Event> inEvents) {
                        _showAppointments(inDate, ctx);
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAppointments(DateTime inDate, BuildContext inContext) async {
    showModalBottomSheet(
      context: inContext,
      builder: (BuildContext ctx) {
        return ScopedModel<AppointmentModel>(
          model: appointmentModel,
          child: ScopedModelDescendant<AppointmentModel>(
            builder: (context, child, model) {
              return Scaffold(
                body: Container(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Text(
                            DateFormat.yMMMMd(I18n.curLang(context)).format(inDate.toLocal()),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).accentColor, fontSize: 24),
                          ),
                          Divider(),
                          Expanded(
                            child: ListView.builder(
                                itemCount: appointmentModel.entityList.length,
                                itemBuilder: (inctx, index) {
                                  Appointment appointment = appointmentModel.entityList[index];
                                  if (appointment.apptDate != "${inDate.year},${inDate.month},${inDate.day}") {
                                    return Container(
                                      height: 0,
                                    );
                                  }
                                  String apptTime = "";
                                  if (appointment.apptTime != null) {
                                    List timeParts = appointment.apptTime.split(",");
                                    TimeOfDay at = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
                                    apptTime = " (${at.format(inctx)})";
                                  }

                                  return Column(children: [
                                    Slidable(
                                      actionPane: SlidableBehindActionPane(),
                                      actionExtentRatio: 0.25,
                                      child: Container(
                                        padding: EdgeInsets.only(bottom: 8),
                                        color: Colors.grey.shade300,
                                        child: ListTile(
                                          title: Text('${appointment.title}$apptTime'),
                                          subtitle: appointment.description == null ? null : Text("${appointment.description}"),
                                          onTap: () async {
                                            _editAppointment(inctx, appointment);
                                          },
                                        ),
                                      ),
                                      secondaryActions: [
                                        IconSlideAction(
                                          caption: "Delete",
                                          color: Colors.red,
                                          icon: Icons.delete,
                                          onTap: () => _deleteAppointment(inctx, appointment),
                                        )
                                      ],
                                    ),
                                    Container(height: 2,)
                                    
                                  ]);
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _editAppointment(BuildContext context, Appointment appointment) async {
    appointmentModel.entityBeingEdited = await AppointmentDBWorker.db.find(appointment.id);
    Appointment apt = appointmentModel.entityBeingEdited;
    if (apt.apptDate == null) {
      appointmentModel.setChosenDate(null);
    } else {
      List dateParts = apt.apptDate.split(",");
      DateTime apptDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
      appointmentModel.setChosenDate(DateFormat.yMMMMd("en_US").format(apptDate.toLocal()));

      if (apt.apptTime == null) {
        appointmentModel.setApptTime(null);
      } else {
        List timeParts = apt.apptTime.split(",");
        TimeOfDay _time = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
        appointmentModel.setApptTime(_time.format(context));
      }
      appointmentModel.setStackIndex(1);
      Navigator.pop(context);
    }
  }

  Future _deleteAppointment(BuildContext context, Appointment appointment) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Delete Appointment'),
          content: Text('Are you sure you want to delete ${appointment.title}'),
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            FlatButton(
                onPressed: () async {
                  await AppointmentDBWorker.db.delete(appointment.id);
                  Navigator.pop(ctx);
                  Scaffold.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text('Appointment deleted'),
                  ));
                  appointmentModel.loadData("appointments", AppointmentDBWorker.db);
                },
                child: Text('Delete'))
          ],
        );
      },
    );
  }
}
