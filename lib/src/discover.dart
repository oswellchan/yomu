import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'sources/base.dart';
import 'sources/mangakakalot.dart';
import 'widgets/manga_row.dart';
import 'widgets/spinner.dart';


class DiscoverState extends State<Discover> {
  final Source _source = Mangakakalot();
  List<Manga> _mangas = <Manga>[];
  bool _fetching = false;
  Cursor _cursor;

  @override
  Widget build(BuildContext context) {
    if (_cursor == null) {
      _cursor = _source.getLatestMangas();
    }

    Widget child;
    if (_mangas.isEmpty) {
      if (!_fetching) {
        _fetchNextList();
      } else {
        child = Center(
          child: Spinner()
        );
      }
    } else {
      child = _buildList();
    }

    return CupertinoPageScaffold(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: child
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemBuilder: (BuildContext _context, int i) {
        if (i * 3 >= _mangas.length) {
          if (!_fetching) {
            _fetchNextList();
            return Spinner();
          }
          return null;
        }

        var start = i * 3;
        if (start + 3 <= _mangas.length) {
          return MangaRow(mangas: _mangas.sublist(start, start + 3));
        }

        return null;
      }
    );
  }

  void _fetchNextList() async {
    _fetching = true;
    var mangas = await _cursor.getNext();
    if (!mounted) return;

    setState(() {
      _mangas.addAll(mangas);
      _fetching = false;
    });
  }
}

class Discover extends StatefulWidget {
  @override
  DiscoverState createState() => DiscoverState();
}
