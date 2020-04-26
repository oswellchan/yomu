import 'package:flutter/material.dart';
import 'src/sources/mangatown.dart';

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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Chapters()
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ChaptersState extends State<Chapters> {
  final MangaTown _source = MangaTown();
  final List<String> _images = <String>[];
  bool loadNewChapter = true;

  @override
  Widget build(BuildContext context) {
    if (!this.loadNewChapter) {
      return _buildPages(this._images);
    }

    var future = FutureBuilder<List<String>>(
      future: _source.getChapterPages('beastars', 172), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        print('Getting images');
        if (snapshot.hasData) {
          _images.addAll(snapshot.data);
        }
        return _buildPages(this._images);
      },
    );
    this.loadNewChapter = false;
    return future;
  }
}

class Chapters extends StatefulWidget {
  @override
  ChaptersState createState() => ChaptersState();
}

Widget _buildPages(List<String> images) {
  return ListView.builder(
    itemCount: images.length,
    itemBuilder: (BuildContext _context, int i) {
      return _buildPage(images[i]);
    }
  );
}

Widget _buildPage(String pageUrl) {
  return Image.network(pageUrl);
}