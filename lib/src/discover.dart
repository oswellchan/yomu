import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'sources/base.dart';
import 'sources/mangatown.dart';
import 'widgets/manga_row.dart';


class DiscoverState extends State<Discover> {
  final MangaTown _source = MangaTown();
  List<Manga> _mangas = <Manga>[];
  bool _notFetching = true;
  MangaTownCursor _cursor;

  @override
  Widget build(BuildContext context) {
    if (_cursor == null) {
      _cursor = _source.getLatestMangas();
    }

    return CupertinoPageScaffold(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemBuilder: (BuildContext _context, int i) {
            if (i * 3 >= _mangas.length) {
              if (_notFetching) {
                _notFetching = false;
                _fetchNextList();
              } else {
                return null;
              }
            }

            var start = i * 3;
            if (start + 3 <= _mangas.length) {
              return MangaRow(mangas: _mangas.sublist(start, start + 3));
            }

            return null;
          }
        )
      )
    );
  }

  void _fetchNextList() async {
    var mangas = await _cursor.getNext();
    if (!mounted) return;

    setState(() {
      _mangas.addAll(mangas);
      _notFetching = true;
    });
  }
}

class Discover extends StatefulWidget {
  @override
  DiscoverState createState() => DiscoverState();
}
