import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../utils.dart' as utils;
import 'models/note.dart';
import 'note_db_worker.dart';

class NotesList extends StatelessWidget {
  const NotesList({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var nm = Provider.of<NoteModel>(context, listen: false);
    var nm = context.watch<NoteModel>();
    print("## notes list build()");

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          // var noteModel = context.read<NoteModel>();
          var noteModel = nm;

          noteModel.entityBeingEdited = Note();
          noteModel.setColor(null);
          noteModel.setStackIndex(1);
        },
      ),
      body: ListView.builder(
        itemCount: nm.entityList.length,
        itemBuilder: (BuildContext inBuildContext, int inIndex) {
          log("---List view builder");

          var noteModel = nm;
          Note note = noteModel.entityList[inIndex];
          Color color = utils.colorByStr(note.color);
          log("---note's color: ${note.color}, note index: $inIndex");

          return Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Slidable(
              actionPane: SlidableScrollActionPane(),
              actionExtentRatio: 0.25,
              secondaryActions: [
                IconSlideAction(
                  icon: Icons.delete,
                  caption: "Delete",
                  color: Colors.red,
                  onTap: () {
                    showDialog(
                      context: inBuildContext,
                      barrierDismissible: false,
                      builder: (inAlertContext) {
                        return AlertDialog(
                          title: Text("Delete Note"),
                          content: Text("Are you sure you want to delete ${note.title}?"),
                          actions: [
                            FlatButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.of(inAlertContext).pop();
                              },
                            ),
                            FlatButton(
                              onPressed: () async {
                                await NoteDBWorker.db.delete(note.id);
                                Navigator.of(inAlertContext).pop();
                                Scaffold.of(inBuildContext).showSnackBar(SnackBar(
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                  content: Text("Note deleted"),
                                ));
                                nm.loadData("notes");
                              },
                              child: Text("Delete"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
              ],
              child: Card(
                margin: EdgeInsets.all(0),
                elevation: 8,
                color: color,
                child: ListTile(
                  title: Text("${note.title}"),
                  subtitle: Text("${note.content}"),
                  onTap: () async {
                    var noteModel = context.read<NoteModel>();
                    noteModel.entityBeingEdited = await NoteDBWorker.db.find(note.id);
                    noteModel.setColor(noteModel.entityBeingEdited.color);
                    noteModel.setStackIndex(1);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
