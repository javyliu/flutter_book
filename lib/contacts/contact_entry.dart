import 'dart:io';
import 'package:flutter_book/contacts/contacts_db_worker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'models/contact.dart';
import '../utils.dart' as utils;

class ContactEntry extends StatelessWidget {
  final TextEditingController _nameCon = TextEditingController();
  final TextEditingController _phoneCon = TextEditingController();
  final TextEditingController _emailCon = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  ContactEntry() {
    _nameCon.addListener(() {
      contactsModel.entityBeingEdited.name = _nameCon.text;
    });
    _phoneCon.addListener(() {
      contactsModel.entityBeingEdited.phone = _phoneCon.text;
    });
    _emailCon.addListener(() {
      contactsModel.entityBeingEdited.email = _emailCon.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (contactsModel.entityBeingEdited != null) {
      Contact _ct = contactsModel.entityBeingEdited;
      _nameCon.text = _ct.name;
      _phoneCon.text = _ct.phone;
      _emailCon.text = _ct.email;
    }

    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (scontext, child, model) {
          File avatarFile = File(join(utils.docsDir.path, "avatar"));
          if (avatarFile.existsSync() == false) {
            if (model.entityBeingEdited?.id != null) {
              avatarFile = File(join(utils.docsDir.path, model.entityBeingEdited.id.toString()));
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
                      FocusScope.of(scontext).requestFocus(FocusNode());
                      model.setStackIndex(0);
                    },
                    child: Text('Cancel'),
                  ),
                  Spacer(),
                  FlatButton(
                    onPressed: () => _save(scontext, model),
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
                    title: avatarFile.existsSync() ? Image.file(avatarFile) : Text('No avatar image for this contact'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () => _selectAvatar(scontext),
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
                        String chosenDate = await utils.selectDate(scontext, contactsModel, contactsModel.entityBeingEdited.birthday);
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
        },
      ),
    );
  }

  void _save(BuildContext context, ContactsModel model) async {
    if(!_formKey.currentState.validate()) return;
    var id;
    if(model.entityBeingEdited.id == null){
      id = await ContactsDBWorker.db.create(contactsModel.entityBeingEdited);

    }else{
      id = contactsModel.entityBeingEdited.id;
      await ContactsDBWorker.db.update(contactsModel.entityBeingEdited);
    }

    File afile = File(join(utils.docsDir.path,"avatar"));
    if(afile.existsSync()){
      afile.renameSync(join(utils.docsDir.path, id.toString()));
      
    }

    contactsModel.loadData("contacts", ContactsDBWorker.db);
    model.setStackIndex(0);
    Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
        content: Text("Contact saved"),
      )
    );

  }

  // ignore: unused_element
  Future _selectAvatar(BuildContext context) {
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
