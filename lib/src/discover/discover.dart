import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../sources/base.dart';
import '../sources/mangatown.dart';


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

    print('building');

    return ListView.builder(
      itemBuilder: (BuildContext _context, int i) {
        if (i >= _mangas.length && _notFetching) {
          _notFetching = false;
          _fetchNextList();
        }
        
        if (i < _mangas.length) {
          return _buildManga(_mangas[i]);
        }
        return null;
      }
    );
  }

  void _fetchNextList() async {
    print('in fetch');
    var mangas = await _cursor.getNext();
    print(mangas);
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

Widget _buildManga(Manga manga) {
  return Column(
    children: <Widget>[
      CachedNetworkImage(
        imageUrl: manga.thumbnailUrl,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
      Text(manga.id),
      Text(manga.name),
      Text(manga.lastUpdated),
    ],
  );
}
