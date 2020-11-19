import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'note_db_worker.dart';
import 'models/note.dart' show NoteModel, noteModel;
import '../utils.dart' as utils;

class NotesEntry extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();

  final TextEditingController _contentEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  NotesEntry() {
    print("## NotesEntry.constuctor");
    _titleEditingController.addListener(() {
      noteModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      noteModel.entityBeingEdited.content = _contentEditingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("## NotesEntry.build()");
    if (noteModel.entityBeingEdited != null) {
      _titleEditingController.text = noteModel.entityBeingEdited.title;
      _contentEditingController.text = noteModel.entityBeingEdited.content;
    }

    return ScopedModel(
      model: noteModel,
      child: ScopedModelDescendant<NoteModel>(
        builder: (inContext, inChild, inModel) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  FlatButton(
                    onPressed: () {
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    },
                    child: Text("Cancel"),
                  ),
                  Spacer(),
                  FlatButton(
                    onPressed: () {
                      FocusScope.of(inContext).requestFocus(FocusNode());

                      _save(inContext, noteModel);
                    },
                    child: Text("Save"),
                  )
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.title),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Title"),
                      controller: _titleEditingController,
                      validator: (value) {
                        if (value.isEmpty) return "please enter a title";
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.content_paste),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      decoration: InputDecoration(hintText: "content"),
                      controller: _contentEditingController,
                      validator: (value) {
                        if (value.isEmpty) return "Please enter content";
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.color_lens),
                    title: Row(
                      children: buildColors(inContext),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> buildColors(BuildContext inContext) {
    List<String> _colors = ["red", "", "green", "", "blue", "", "yellow", "", "grey", "", "purple"];

    return _colors.map((item) {
      if (item.isEmpty) return Spacer();
      return GestureDetector(
        child: Container(
          decoration: ShapeDecoration(
            shape: Border.all(color: utils.colorByStr(item), width: 18) + Border.all(width: 6, color: noteModel.color == item ? utils.colorByStr(item) : Theme.of(inContext).canvasColor),
          ),
        ),
        onTap: () {
          noteModel.entityBeingEdited.color = item;
          noteModel.setColor(item);
        },
      );
    }).toList();
  }

  void _save(BuildContext context, NoteModel inmodel) async {
    if (!_formKey.currentState.validate()) return;

    if (inmodel.entityBeingEdited.id == null) {
      await NoteDBWorker.db.create(noteModel.entityBeingEdited);
    } else {
      await NoteDBWorker.db.update(noteModel.entityBeingEdited);
    }
    noteModel.loadData("notes", NoteDBWorker.db);

    inmodel.setStackIndex(0);

    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Note saved"),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green,
    ));
  }
}