import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_book/appointments/appointments.dart';
import 'package:flutter_book/contacts/contacts.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'i18n.dart';
import 'notes/notes.dart';
import 'tasks/tasks.dart';
import 'utils.dart' as utils;

void main() {
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
      useCountryCode: false,
      fallbackFile: 'zh',
      basePath: 'assets/i18n',
      forcedLocale: Locale('zh'),
    ),
  );

  WidgetsFlutterBinding.ensureInitialized();
  print("## main(): FlutterBook Starting");

  startUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    await flutterI18nDelegate.load(null);
    runApp(MyApp(flutterI18nDelegate));
  }

  startUp();
}

class MyApp extends StatelessWidget {
  final FlutterI18nDelegate flutterI18nDelegate;

  MyApp(this.flutterI18nDelegate);

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
      // locale: Locale("zh"),
      localizationsDelegates: [
        flutterI18nDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('zh', ''),
      ],
      builder: FlutterI18n.rootAppBuilder(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget  {
  const HomePage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("-------${Localizations.localeOf(context)}-----------------");
    print("--------${FlutterI18n.currentLocale(context)}----------------");
    print("--------${MaterialLocalizations.of(context).backButtonTooltip}----------------");
    print("--------${FlutterI18n.currentLocale(context)}----------------");
    print("--------${I18n.t(context,"tabs")}----------------");
    print("---21-----${Intl.systemLocale}----------------");

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: I18nText("app_name"),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.date_range),
                text: I18n.t(context,"tabs.Appointments"),
              ),
              Tab(
                icon: Icon(Icons.contacts),
                text: I18n.t(context,"tabs.Contacts"),
              ),
              Tab(
                icon: Icon(Icons.note),
                text: I18n.t(context,"tabs.Notes"),
              ),
              Tab(icon: Icon(Icons.assignment_turned_in), text: I18n.t(context,"tabs.Task")),
            ],
          ),
        ),
        body: TabBarView(children: [
          Appointments(),
          Contacts(),
          Notes(),
          Tasks(),
        ]),
      ),
    );
  }
}
