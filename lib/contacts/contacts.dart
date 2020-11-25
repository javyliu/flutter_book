import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_book/contacts/contact_entry.dart';
import 'package:provider/provider.dart';

import 'contact_list.dart';
import 'models/contact.dart';

class Contacts extends StatelessWidget {
  Contacts() {
    log("----------Contact constructor");
    model.loadData("contacts");
  }

  @override
  Widget build(BuildContext context) {
    log("--contacts build");
    return ChangeNotifierProvider.value(
      value: model,
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

    var idx = context.select<ContactModel, int>((item) => item.stackIndex);
    // var idx = Provider.of<ContactModel>(context).stackIndex;
    return IndexedStack(
      index: idx,
      children: [
        ContactsList(),
        ContactEntry(),
      ],
    );
  }
}
