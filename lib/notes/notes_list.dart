
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'notes_db_worker.dart';
import 'notes_model.dart';
import '../utils.dart' as utils;

class NotesList extends StatelessWidget {
  const NotesList({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          notesModel.entityBeingEdited = Note();
          notesModel.setColor(null);
          notesModel.setStackIndex(1);
        },
      ),
      body: ListView.builder(
        itemCount: notesModel.entityList.length,
        itemBuilder: (BuildContext inBuildContext, int inIndex) {
          Note note = notesModel.entityList[inIndex];
          Color color = utils.colorByStr(note.color);

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
                                await NotesDBWorker.db.delete(note.id);
                                Navigator.of(inAlertContext).pop();
                                Scaffold.of(inBuildContext).showSnackBar(SnackBar(
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                  content: Text("Note deleted"),
                                ));
                                notesModel.loadData("notes", NotesDBWorker.db);
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
                    notesModel.entityBeingEdited = await NotesDBWorker.db.find(note.id);
                    notesModel.setColor(notesModel.entityBeingEdited.color);
                    notesModel.setStackIndex(1);
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
