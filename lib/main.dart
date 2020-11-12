import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'notes/notes.dart';
import 'tasks/tasks.dart';
import 'utils.dart' as utils;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  print("## main(): FlutterBook Starting");

  startUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    
    utils.docsDir = docsDir;
    runApp(MyApp());
  }

  startUp();
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    print("## FlutterBook.build()");

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Flutter Book"),
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.date_range),
                  text: "Appointments",
                ),
                Tab(
                  icon: Icon(Icons.contacts),
                  text: "Contacts",
                ),
                Tab(
                  icon: Icon(Icons.note),
                  text: "Notes",
                ),
                Tab(icon: Icon(Icons.assignment_turned_in), text: "Task"),
              ],
            ),
          ),
          body: TabBarView(children: [
            Text("Appointment TODO"),
            Text("Contacts TODO"),
            Notes(),
            Tasks(),
            
          ]),
        ),
      ),
    );
  }
}
