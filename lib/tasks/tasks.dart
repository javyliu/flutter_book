import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import '../i18n.dart';
import 'models/task.dart';
import 'task_entry.dart';
import 'task_db_worker.dart';

class Tasks extends StatelessWidget {
  Tasks({
    Key key,
  }) : super(key: key) {
    taskModel.loadData("tasks", TasksDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TaskModel>(
      model: taskModel,
      child: ScopedModelDescendant<TaskModel>(
        builder: (context, child, model) {
          return IndexedStack(index: model.stackIndex, children: [TasksList(), TasksEntry()]);
        },
      ),
    );
  }
}

class TasksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          taskModel.entityBeingEdited = Task();
          taskModel.setChosenDate(null);
          taskModel.setStackIndex(1);
        },
      ),
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        itemCount: taskModel.entityList.length,
        itemBuilder: (ctx, index) {
          Task tsk = taskModel.entityList[index];
          String sDate;
          if (tsk.dueDate != null) {
            List dateParts = tsk.dueDate.split(",").map((e) => int.parse(e)).toList();
            DateTime dueDate = DateTime(dateParts[0], dateParts[1], dateParts[2]);
            sDate = DateFormat.yMMMMd(I18n.curLang(context)).format(dueDate.toLocal());
          }

          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: .25,
            child: ListTile(
              leading: Checkbox(
                value: tsk.completed == "true" ? true : false,
                onChanged: (value) async {
                  tsk.completed = value.toString();
                  await TasksDBWorker.db.update(tsk);
                  taskModel.loadData("tasks", TasksDBWorker.db);
                },
              ),
              title: Text(
                '${tsk.description}',
                style: tsk.completed == "true" ? TextStyle(color: Theme.of(ctx).disabledColor, decoration: TextDecoration.lineThrough) : TextStyle(color: Theme.of(ctx).textTheme.headline6.color),
              ),
              subtitle: tsk.dueDate == null
                  ? null
                  : Text(
                      sDate,
                      style:
                          tsk.completed == "true" ? TextStyle(color: Theme.of(ctx).disabledColor, decoration: TextDecoration.lineThrough) : TextStyle(color: Theme.of(ctx).textTheme.headline6.color),
                    ),
              onTap: () async {
                if (tsk.completed == "true") return;
                taskModel.entityBeingEdited = await TasksDBWorker.db.find(tsk.id);
                if (taskModel.entityBeingEdited.dueDate == null) {
                  taskModel.setChosenDate(null);
                } else {
                  taskModel.setChosenDate(sDate);
                }
                taskModel.setStackIndex(1);
              },
            ),
            secondaryActions: [
              IconSlideAction(
                caption: "Delete",
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => _deleteTask(ctx, tsk),
              )
            ],
          );
        },
      ),
    );
  }

  Future _deleteTask(BuildContext context, Task task) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete ${task.description}?'),
          actions: [
            FlatButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel'),
            ),
            FlatButton(
              onPressed: () async {
                await TasksDBWorker.db.delete(task.id);
                Navigator.of(ctx).pop();
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Task deleted'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                ));
                taskModel.loadData("tasks", TasksDBWorker.db);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
