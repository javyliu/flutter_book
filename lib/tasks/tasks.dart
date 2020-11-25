import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'models/task.dart';
import 'task_db_worker.dart';
import 'task_entry.dart';

class Tasks extends StatelessWidget {
  Tasks() {
    model.loadData("tasks");
  }
  @override
  Widget build(BuildContext context) {
    log("---tasks build");

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
    var idx = context.select<TaskModel, int>((value) => value.stackIndex);
    return IndexedStack(
      index: idx,
      children: [
        TasksList(),
        TaskEntry(),
      ],
    );
  }
}

class TasksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    log("---tasks list build");

    var taskModel = context.watch<TaskModel>();

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
            sDate = DateFormat.yMMMMd(Intl.getCurrentLocale()).format(dueDate.toLocal());
          }

          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: .25,
            child: ListTile(
              leading: Checkbox(
                value: tsk.completed == "true" ? true : false,
                onChanged: (value) async {
                  tsk.completed = value.toString();
                  await TaskDBWorker.dbWorker.update(tsk);
                  taskModel.loadData("tasks");
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
                taskModel.entityBeingEdited = await TaskDBWorker.dbWorker.find(tsk.id);
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
                await TaskDBWorker.dbWorker.delete(task.id);
                Navigator.of(ctx).pop();
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Task deleted'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                ));
                var taskModel = context.read<TaskModel>();
                taskModel.loadData("tasks");
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
