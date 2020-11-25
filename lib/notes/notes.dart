import 'package:flutter/material.dart';
import 'package:flutter_book/notes/note_entry.dart';
import 'package:provider/provider.dart';

import 'models/note.dart';
import 'notes_list.dart';

class Notes extends StatelessWidget {
  Notes() {
    model.loadData("notes");
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: model,
      child: IdxStack(),
    );
  }
}

class IdxStack extends StatelessWidget {
  const IdxStack({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var idx = context.select<NoteModel, int>((value) => value.stackIndex);
    return IndexedStack(
      index: idx,
      children: [
        NotesList(),
        NotesEntry(),
      ],
    );
  }
}
