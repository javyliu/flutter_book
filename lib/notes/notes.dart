import 'package:flutter/material.dart';
import 'package:flutter_book/notes/note_entry.dart';
import 'package:scoped_model/scoped_model.dart';

import 'models/note.dart';
import 'note_db_worker.dart';
import 'notes_list.dart';

class Notes extends StatelessWidget {
  Notes() {
    print("## Notes.constructor");
    noteModel.loadData("notes", NoteDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<NoteModel>(
      model: noteModel,
      child: ScopedModelDescendant<NoteModel>(
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
