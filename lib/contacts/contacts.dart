import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_book/contacts/contact_entry.dart';
import 'package:provider/provider.dart';

import 'contact_list.dart';
import 'models/contact.dart';

class Contacts extends StatelessWidget {
  Contacts() {
    // contactsModel.loadData("contacts", ContactsDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    log("--contacts build");

    return ChangeNotifierProvider(
      create: (context) {
        ContactsModel cm = ContactsModel();
        cm.loadData("contacts");
        return cm;
      },
      child: WIndexedStack(),
    );
  }
}

class WIndexedStack extends StatelessWidget {
  const WIndexedStack({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log("--contact windexedstack build");

    var idx = context.select<ContactsModel, int>((item) => item.stackIndex);
    return IndexedStack(
      index: idx,
      children: [
        ContactsList(),
        ContactEntry(),
      ],
    );
  }
}
