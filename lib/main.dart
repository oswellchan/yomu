import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/discover.dart';
import 'src/manga_overview.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Flutter Demo',
      theme: new CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.black,
        barBackgroundColor: CupertinoColors.black,
        scaffoldBackgroundColor: CupertinoColors.black,
        textTheme: new CupertinoTextThemeData(
          primaryColor: CupertinoColors.white,
          textStyle: TextStyle(color: CupertinoColors.white),
        ),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    Route page;
    switch (settings.name) {
      case "/":
        page = CupertinoPageRoute(
          title: 'Discover',
          settings: settings,
          builder: (context) => Discover(),
        );
        break;
      case "/manga":
        page = CupertinoPageRoute(
          title: 'Manga',
          fullscreenDialog: true,
          settings: settings,
          builder: (context) => MangaOverview(),
        );
        break;
    }
    return page;
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Discover')
      ),
      child: Center(
        child: Discover(),
      ),
    );
  }
}
