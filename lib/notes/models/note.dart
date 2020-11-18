import 'dart:convert';

import '../../base_model.dart';

class Note {
  int id;
  String title;
  String content;
  String color;
  Note({this.id, this.title, this.content, this.color});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
    };
  }

  

  factory Note.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      color: map['color'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) => Note.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Note(id: $id, title: $title, content: $content, color: $color)';
  }
}

class NoteModel extends BaseModel {
  String color;
  void setColor(String color) {
    color = color;
    notifyListeners();
  }
}

NoteModel noteModel = NoteModel();
