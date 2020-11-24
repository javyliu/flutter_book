import 'package:flutter/material.dart';
import 'package:flutter_book/tasks/task_db_worker.dart';
import 'package:provider/provider.dart';

import 'models/task.dart';
import '../utils.dart' as utils;

///任务新建/编辑
class TaskEntry extends StatelessWidget {
  final TextEditingController _descriptionEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TaskEntry() {
    // _descriptionEditingController.addListener(() {
    //   taskModel.entityBeingEdited.description = _descriptionEditingController.text;
    // });
  }

  @override
  Widget build(BuildContext context) {
    var taskModel = context.watch<TaskModel>();
    _descriptionEditingController.addListener(() {
      taskModel.entityBeingEdited.description = _descriptionEditingController.text;
    });
    if (taskModel.entityBeingEdited != null) {
      _descriptionEditingController.text = taskModel.entityBeingEdited.description;
    }

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: Row(
          children: [
            FlatButton(
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                taskModel.setStackIndex(0);
              },
              child: Text('Cancel'),
            ),
            Spacer(),
            FlatButton(
              onPressed: () {
                _save(context, taskModel);
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
                  if (value.isEmpty) return "Please enter a description";
                  return null;
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.today),
              title: Text("Due Date"),
              subtitle: Text(taskModel.chosenDate == null ? "" : taskModel.chosenDate),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                color: Colors.blue,
                onPressed: () async {
                  String chosenDate = await utils.selectDate(context, taskModel, taskModel.entityBeingEdited.dueDate);
                  if (chosenDate != null) {
                    taskModel.entityBeingEdited.dueDate = chosenDate;
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future _save(BuildContext context, TaskModel model) async {
    if (!_formKey.currentState.validate()) return;

    if (model.entityBeingEdited.id == null) {
      await TaskDBWorker.dbWorker.create(model.entityBeingEdited);
    } else {
      await TaskDBWorker.dbWorker.update(model.entityBeingEdited);
    }

    model.loadData("tasks");
    model.setStackIndex(0);

    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      content: Text('Task saved'),
    ));
  }
}
