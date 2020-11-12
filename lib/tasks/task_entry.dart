import 'package:flutter/material.dart';
import 'package:flutter_book/tasks/tasksDBWorker.dart';
import 'package:scoped_model/scoped_model.dart';

import 'models/task.dart';
import '../utils.dart' as utils;

class TasksEntry extends StatelessWidget {
  final TextEditingController _descriptionEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry() {
    _descriptionEditingController.addListener(() {
      tasksModel.entityBeingEdited.description = _descriptionEditingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (tasksModel.entityBeingEdited != null) {
      _descriptionEditingController.text = tasksModel.entityBeingEdited.description;
    }

    return ScopedModel<TasksModel>(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (ctx, child, model) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  FlatButton(
                    onPressed: () {
                      FocusScope.of(ctx).requestFocus(FocusNode());
                      model.setStackIndex(0);
                    },
                    child: Text('Cancel'),
                  ),
                  Spacer(),
                  FlatButton(
                    onPressed: () {
                      _save(ctx, tasksModel);
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      decoration: InputDecoration(hintText: "Description"),
                      controller: _descriptionEditingController,
                      validator: (value) {
                        if(value.isEmpty) return "Please enter a description";
                        return null;
                      },
                    ),

                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text("Due Date"),
                    subtitle: Text(tasksModel.chosenDate == null ? "" : tasksModel.chosenDate),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async{
                        String chosenDate = await utils.selectDate(ctx, tasksModel, tasksModel.entityBeingEdited.dueDate);
                        if(chosenDate != null){
                          tasksModel.entityBeingEdited.dueDate = chosenDate;
                        }
                      },
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

  Future _save(BuildContext context, TasksModel model) async {
    if(!_formKey.currentState.validate()) return;

    if(model.entityBeingEdited.id == null){
      await TasksDBWorker.db.create(tasksModel.entityBeingEdited);
    }else{
      await TasksDBWorker.db.update(tasksModel.entityBeingEdited);
    }

    tasksModel.loadData("tasks", TasksDBWorker.db);
    model.setStackIndex(0);
    
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      content: Text('Task saved'),
    ));
  }
}
