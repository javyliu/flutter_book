import '../../base_model.dart';

class Task {
  int id;
  String description;
  String dueDate;
  String completed;

  Task({this.id, this.description, this.dueDate, this.completed = "false"});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      description: json['description'],
      dueDate: json['dueDate'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    data['dueDate'] = this.dueDate;
    data['completed'] = this.completed;
    return data;
  }
}

class TaskModel extends BaseModel {}

TaskModel taskModel = TaskModel();
