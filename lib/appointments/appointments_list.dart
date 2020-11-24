import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_book/generated/l10n.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'appointment_db_worker.dart';
import 'models/appointment.dart';

class AppointmentsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    EventList<Event> _markedDateMap = EventList();

    var am = context.watch<AppointmentModel>();

    for (Appointment item in am.entityList) {
      List dateParts = item.apptDate.split(",").map((e) => int.parse(e)).toList();
      DateTime aptDate = DateTime(dateParts[0], dateParts[1], dateParts[2]);
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

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          am.entityBeingEdited = Appointment();
          Appointment _edited = am.entityBeingEdited;
          DateTime now = DateTime.now();
          _edited.apptDate = "${now.year}, ${now.month},${now.day}";
          am.setChosenDate(DateFormat.yMMMMd("en_US").format(now.toLocal()));
          am.setApptTime(null);
          am.setStackIndex(1);
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
                locale: Intl.getCurrentLocale(),
                thisMonthDayBorderColor: Colors.grey,
                daysHaveCircularBorder: true,
                markedDatesMap: _markedDateMap,
                onDayPressed: (DateTime inDate, List<Event> inEvents) {
                  _showAppointments(inDate, context, am);
                },
              ),
            ),
          ),
          FlatButton(
              onPressed: () async {
                print("current local: ${Intl.getCurrentLocale()}");
                var needLocal = S.delegate.supportedLocales.firstWhere((element) => element.languageCode != Intl.getCurrentLocale());
                log("need local: $needLocal");

                await S.load(needLocal);
                // ScopedModel.of<AppointmentModel>(context).notifyListeners();

                print("----changed-${Intl.getCurrentLocale()}");
              },
              child: Text('change the language')),
          Spacer(
            flex: 1,
          )
        ],
      ),
    );
  }

  void _showAppointments(DateTime inDate, BuildContext inContext, AppointmentModel am) async {
    showModalBottomSheet(
      context: inContext,
      builder: (BuildContext ctx) {
        return Container(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: GestureDetector(
              child: Column(
                children: [
                  Text(
                    DateFormat.yMMMMd(Intl.getCurrentLocale()).format(inDate.toLocal()),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(ctx).accentColor, fontSize: 24),
                  ),
                  Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: am.entityList.length,
                      itemBuilder: (inctx, index) {
                        Appointment appointment = am.entityList[index];
                        if (appointment.apptDate != "${inDate.year},${inDate.month},${inDate.day}") {
                          return Container(
                            height: 0,
                          );
                        }
                        String apptTime = "";
                        if (appointment.apptTime != null) {
                          List timeParts = appointment.apptTime.split(",").map((e) => int.parse(e)).toList();
                          TimeOfDay at = TimeOfDay(hour: timeParts[0], minute: timeParts[1]);
                          apptTime = " (${at.format(inctx)})";
                        }

                        return Column(
                          children: [
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
                                    _editAppointment(inctx, appointment, am);
                                  },
                                ),
                              ),
                              secondaryActions: [
                                IconSlideAction(
                                  caption: "Delete",
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () => _deleteAppointment(inctx, appointment, am),
                                )
                              ],
                            ),
                            Container(
                              height: 2,
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _editAppointment(BuildContext context, Appointment appointment, AppointmentModel am) async {
    am.entityBeingEdited = await AppointmentDBWorker.db.find(appointment.id);
    Appointment apt = am.entityBeingEdited;
    if (apt.apptDate == null) {
      am.setChosenDate(null);
    } else {
      List dateParts = apt.apptDate.split(",").map((e) => int.parse(e)).toList();
      DateTime apptDate = DateTime(dateParts[0], dateParts[1], dateParts[2]);
      am.setChosenDate(DateFormat.yMMMMd(Intl.getCurrentLocale()).format(apptDate.toLocal()));

      if (apt.apptTime == null) {
        am.setApptTime(null);
      } else {
        List timeParts = apt.apptTime.split(",").map((e) => int.parse(e)).toList();
        TimeOfDay _time = TimeOfDay(hour: timeParts[0], minute: timeParts[1]);
        am.setApptTime(_time.format(context));
      }
      am.setStackIndex(1);
      Navigator.pop(context);
    }
  }

  Future _deleteAppointment(BuildContext context, Appointment appointment, AppointmentModel am) async {
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
                  am.loadData("appointments");
                },
                child: Text('Delete'))
          ],
        );
      },
    );
  }
}
