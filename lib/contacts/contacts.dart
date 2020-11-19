import 'package:flutter/material.dart';
import 'package:flutter_book/contacts/contact_entry.dart';
import 'package:scoped_model/scoped_model.dart';

import 'contact_list.dart';
import 'contacts_db_worker.dart';
import 'models/contact.dart';

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
