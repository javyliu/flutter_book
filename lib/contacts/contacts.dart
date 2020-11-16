import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_book/contacts/contact_entry.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'contacts_db_worker.dart';
import 'models/contact.dart';
import '../utils.dart' as utils;
import 'package:path/path.dart';

class Contacts extends StatelessWidget {
  Contacts() {
    contactsModel.loadData("contacts", ContactsDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (context, child, model) {
          return IndexedStack(
            index: model.stackIndex,
            children: [
              ContactsList(),
              ContactEntry(),
            ],
          );
        },
      ),
    );
  }
}

class ContactsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (context, child, model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                File avatarFile = File(join(utils.docsDir.path, "avatar"));
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }

                contactsModel.entityBeingEdited = Contact();
                contactsModel.setChosenDate(null);
                contactsModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              itemCount: contactsModel.entityList.length,
              itemBuilder: (lcontext, index) {
                Contact contact = contactsModel.entityList[index];
                File avatarFile = File(join(utils.docsDir.path, contact.id.toString()));
                bool avatarFileExists = avatarFile.existsSync();

                //相同的变量在字widget中可以重复定义么？
                return Column(
                  children: [
                    Slidable(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          backgroundImage: avatarFileExists ? FileImage(avatarFile) : null,
                          child: avatarFileExists ? null : Text(contact.name.substring(0, 1).toUpperCase()),
                        ),
                        title: Text('${contact.name}'),
                        subtitle: contact.phone == null ? null : Text('${contact.phone}'),
                        onTap: () async {
                          File avatarFile = File(join(utils.docsDir.path, "avatar"));
                          if (avatarFile.existsSync()) {
                            avatarFile.deleteSync();
                          }
                          contactsModel.entityBeingEdited = await ContactsDBWorker.db.find(contact.id);
                          if (contactsModel.entityBeingEdited.birthday == null) {
                            contactsModel.setChosenDate(null);
                          } else {
                            List dateParts = contactsModel.entityBeingEdited.birthday.split(",");
                            DateTime birthday = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
                            contactsModel.setChosenDate(DateFormat.yMMMMd("en-US").format(birthday.toLocal()));
                          }
                          contactsModel.setStackIndex(1);
                        },
                      ),
                      actionPane: SlidableBehindActionPane(),
                      actionExtentRatio: 0.25,
                      secondaryActions: [
                        IconSlideAction(
                          caption: "Delete",
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () {
                            _deleteContact(context, contact);
                          },
                        )
                      ],
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future _deleteContact(BuildContext context, Contact contact) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (scontext) {
        return AlertDialog(
          title: Text("Delete Contact"),
          content: Text("Are you sure you want to delete ${contact.name}"),
          actions: [
            FlatButton(onPressed: () => Navigator.of(scontext).pop(), child: Text('Cancel')),
            FlatButton(
              child: Text('Delete'),
              onPressed: () async {
                File avatarFile = File(join(utils.docsDir.path, contact.id.toString()));
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }
                await ContactsDBWorker.db.delete(contact.id);
                Navigator.of(scontext).pop();
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Contact deleted'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                ));
                contactsModel.loadData("contacts", ContactsDBWorker.db);
              },
            )
          ],
        );
      },
    );
  }
}
