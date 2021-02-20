import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'sources/base.dart';
import 'sources/mangakakalot.dart';
import 'widgets/manga_long_tile.dart';
import 'widgets/spinner.dart';

class RecentState extends State<Recent> {
  final Source _source = Mangakakalot();
  List _mangas = <dynamic>[];
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.shouldReload) {
      setState(() {
        _done = false;
      });
    }

    if (widget.shouldReload && !_done) {
      _fetchData();
      return Center(child: Spinner());
    }

    return Container(padding: const EdgeInsets.all(8.0), child: _buildList());
  }

  Widget _buildList() {
    return ListView.separated(
        separatorBuilder: (context, index) => Padding(
              padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
              child: Divider(
                color: CupertinoColors.systemGrey,
              ),
            ),
        itemCount: _mangas.length,
        itemBuilder: (BuildContext _context, int i) {
          return Padding(
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: MangaLongTile(
                manga: _mangas[i][0],
                chapter: _mangas[i][1],
              ));
        });
  }

  void _fetchData() async {
    _done = false;
    var data = await _source.getRecentMangas(50);
    if (!mounted) return;

    setState(() {
      _mangas = data;
      _done = true;
    });
  }
}

class Recent extends StatefulWidget {
  final bool shouldReload;

  Recent({@required this.shouldReload});

  @override
  RecentState createState() => RecentState();
}
