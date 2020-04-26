import 'package:flutter/material.dart';
import 'package:yomu/src/sources/mangatown.dart';
import 'src/reader/reader.dart';
import 'src/discover/discover.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _page = 0;

  void _togglePage() {
    setState(() {
      _page = (_page + 1) % 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;

    if (_page == 0) {
      page = Reader();
    } else {
      page = Discover();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: page
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _togglePage,
        child: Icon(Icons.add),
      ),
    );
  }
}
