import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/contacts/contacts_db_worker.dart';

class Contact {
  int id;
  String name;
  String phone;
  String email;
  String birthday;

  Contact({this.id, this.name, this.phone, this.email, this.birthday});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      birthday: json['birthday'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['birthday'] = this.birthday;
    return data;
  }
}

class ContactModel extends BaseModel {
  ContactModel() {
    dbWorker = ContactDBWorker.db;
  }
  void triggerRebuild() {
    print("## ContactModel.triggerRebuild()");
    notifyListeners();
  }
}

final ContactModel model = ContactModel();
