import 'package:flutter/material.dart';
import 'package:flutter_book/notes/notes_entry.dart';
import 'package:flutter_book/notes/notes_model.dart';
import 'package:scoped_model/scoped_model.dart';

import 'notes_db_worker.dart';
import 'notes_list.dart';

class Notes extends StatelessWidget {
  Notes() {
    print("## Notes.constructor");
    notesModel.loadData("notes", NotesDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<NotesModel>(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
        builder: (context, child, model) {
          return IndexedStack(
            index: model.stackIndex,
            children: [
              NotesList(),
              NotesEntry(),
            ],
          );
        },
      ),
    );
  }
}
