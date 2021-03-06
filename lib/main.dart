import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/discover.dart';
import 'src/manga_overview.dart';
import 'src/search.dart';
import 'src/reader/reader.dart';
import 'src/recent.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

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
      navigatorObservers: [routeObserver],
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    Route page;
    switch (settings.name) {
      case '/':
        page = CupertinoPageRoute(
          title: 'Discover',
          settings: settings,
          builder: (context) => Discover(),
        );
        break;
      case '/manga':
        page = CupertinoPageRoute(
          title: 'Manga',
          fullscreenDialog: true,
          settings: settings,
          builder: (context) => MangaOverview(
            routeObserver: routeObserver,
          ),
        );
        break;
      case '/read':
        page = CupertinoPageRoute(
          fullscreenDialog: true,
          settings: settings,
          builder: (context) => Reader(),
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
  int _currentIndex = 0;

  void setCurrentIndex(index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: CupertinoColors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.compass),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.time),
            label: 'Recent',
          ),
        ],
        onTap: setCurrentIndex,
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                navigationBar:
                    CupertinoNavigationBar(middle: const Text('Discover')),
                child: Discover(),
              );
            });
          case 1:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                resizeToAvoidBottomInset: false,
                child: Search(),
              );
            });
          case 2:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                resizeToAvoidBottomInset: false,
                navigationBar:
                    CupertinoNavigationBar(middle: const Text('Recent')),
                child: Recent(
                  shouldReload: _currentIndex == 2,
                ),
              );
            });
        }
      },
    );
  }
}
