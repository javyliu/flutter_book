import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_book/contacts/contacts_db_worker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';

import '../utils.dart' as utils;
import 'models/contact.dart';

class ContactEntry extends StatelessWidget {
  final TextEditingController _nameCon = TextEditingController();
  final TextEditingController _phoneCon = TextEditingController();
  final TextEditingController _emailCon = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  ContactEntry() {
    // var contactsModel = model;
  }

  @override
  Widget build(BuildContext context) {
    log("-- contact entry build");
    var contactsModel = Provider.of<ContactModel>(context, listen: false);
    _nameCon.addListener(() {
      contactsModel.entityBeingEdited.name = _nameCon.text;
    });
    _phoneCon.addListener(() {
      contactsModel.entityBeingEdited.phone = _phoneCon.text;
    });
    _emailCon.addListener(() {
      contactsModel.entityBeingEdited.email = _emailCon.text;
    });

    if (contactsModel.entityBeingEdited != null) {
      Contact _ct = contactsModel.entityBeingEdited;
      _nameCon.text = _ct.name;
      _phoneCon.text = _ct.phone;
      _emailCon.text = _ct.email;
    }

    File avatarFile = File(join(utils.docsDir.path, "avatar"));
    if (avatarFile.existsSync() == false) {
      if (contactsModel.entityBeingEdited?.id != null) {
        avatarFile = File(join(utils.docsDir.path, contactsModel.entityBeingEdited.id.toString()));
      }
    }
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 10,
        ),
        child: Row(
          children: [
            FlatButton(
              onPressed: () {
                File afile = File(join(utils.docsDir.path, "avatar"));
                if (afile.existsSync()) {
                  afile.deleteSync();
                }
                FocusScope.of(context).requestFocus(FocusNode());
                contactsModel.setStackIndex(0);
              },
              child: Text('Cancel'),
            ),
            Spacer(),
            FlatButton(
              onPressed: () => _save(context, contactsModel),
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
              leading: Text(''),
              title: avatarFile.existsSync()
                  ? CircleAvatar(
                      backgroundImage: FileImage(avatarFile),
                      radius: 100,
                      child: Text(_nameCon.text.isEmpty ? "" : _nameCon.text.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 80,
                          )),
                      // child: Image.file(avatarFile),
                    )
                  : Text('No avatar image for this contact'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                color: Colors.blue,
                onPressed: () => _selectAvatar(context),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: TextFormField(
                decoration: InputDecoration(hintText: "Name"),
                controller: _nameCon,
                validator: (value) {
                  if (value.isEmpty) return "please enter a name";
                  return null;
                },
              ),
            ),
            ListTile(
                leading: Icon(Icons.phone),
                title: TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(hintText: "Phone"),
                  controller: _phoneCon,
                )),
            ListTile(
              leading: Icon(Icons.email),
              title: TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: "Email"),
                controller: _emailCon,
              ),
            ),
            ListTile(
              leading: Icon(Icons.today),
              title: Text("Birthday"),
              subtitle: Text(contactsModel.chosenDate == null ? "" : contactsModel.chosenDate),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                color: Colors.blue,
                onPressed: () async {
                  String chosenDate = await utils.selectDate(context, contactsModel, contactsModel.entityBeingEdited.birthday);
                  if (chosenDate != null) {
                    contactsModel.entityBeingEdited.birthday = chosenDate;
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _save(BuildContext context, ContactModel model) async {
    if (!_formKey.currentState.validate()) return;
    var id;
    if (model.entityBeingEdited.id == null) {
      id = await ContactDBWorker.db.create(model.entityBeingEdited);
    } else {
      id = model.entityBeingEdited.id;
      await ContactDBWorker.db.update(model.entityBeingEdited);
    }

    File afile = File(join(utils.docsDir.path, "avatar"));
    if (afile.existsSync()) {
      afile.renameSync(join(utils.docsDir.path, id.toString()));
    }

    model.loadData("contacts");
    model.setStackIndex(0);
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 2),
      content: Text("Contact saved"),
    ));
  }

  // ignore: unused_element
  Future _selectAvatar(BuildContext context) {
    var contactsModel = context.read<ContactModel>();
    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: Text('Take a picture'),
                  onTap: () async {
                    var cameraImage = await ImagePicker().getImage(source: ImageSource.camera);
                    if (cameraImage != null) {
                      File(cameraImage.path).copySync(join(utils.docsDir.path, "avatar"));
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(ctx).pop();
                  },
                ),
                Padding(padding: EdgeInsets.all(10)),
                GestureDetector(
                  child: Text('Select From Gallery'),
                  onTap: () async {
                    var galleryImage = await ImagePicker().getImage(source: ImageSource.gallery);
                    if (galleryImage != null) {
                      File(galleryImage.path).copySync(join(utils.docsDir.path, "avatar"));
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
