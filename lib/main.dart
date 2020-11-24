import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_book/appointments/appointments.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'contacts/contacts.dart';
import 'generated/l10n.dart';
import 'notes/notes.dart';
import 'tasks/tasks.dart';
import 'utils.dart' as utils;

void main() {
  // final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
  //   translationLoader: FileTranslationLoader(
  //     useCountryCode: false,
  //     fallbackFile: 'zh',
  //     basePath: 'assets/i18n',
  //     forcedLocale: Locale('zh'),
  //   ),
  // );

  WidgetsFlutterBinding.ensureInitialized();
  print("## main(): FlutterBook Starting");

  startUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    // await flutterI18nDelegate.load(null);
    // runApp(MyApp(flutterI18nDelegate));
    runApp(MyApp());
  }

  startUp();
}

class MyApp extends StatelessWidget {
  // final FlutterI18nDelegate flutterI18nDelegate;

  // MyApp(this.flutterI18nDelegate);

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
        // flutterI18nDelegate,
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // supportedLocales: [
      //   const Locale('en', ''),
      //   const Locale('zh', ''),
      // ],
      supportedLocales: S.delegate.supportedLocales,
      // builder: FlutterI18n.rootAppBuilder(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("-------${Localizations.localeOf(context)}-----------------");
    print("---not current lang----${S.delegate.supportedLocales.firstWhere((element) => element.countryCode != Intl.getCurrentLocale())}-----------------");
    print("--------${MaterialLocalizations.of(context).backButtonTooltip}----------------");
    print("---21-----${Intl.systemLocale}------${Intl.getCurrentLocale()}--------");
    var testAry = [1, 2, 3, 4, 5, 6, 7];
    print(testAry.getRange(1, 3));
    print(testAry.sublist(1, 3));

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).app_name),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.date_range),
                text: S.of(context).appointments,
              ),
              Tab(
                icon: Icon(Icons.contacts),
                text: S.of(context).contacts,
              ),
              Tab(
                icon: Icon(Icons.note),
                text: S.of(context).notes,
              ),
              Tab(icon: Icon(Icons.assignment_turned_in), text: S.of(context).task),
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
