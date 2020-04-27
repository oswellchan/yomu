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

    return Container(
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
            return _buildRow(_mangas.sublist(start, start + 3));
          }

          return null;
        }
      )
    );
  }

  void _fetchNextList() async {
    var mangas = await _cursor.getNext();
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

Widget _buildRow(List<Manga> mangas) {
  var widgets = <Widget>[];
  mangas.forEach((manga) {
    widgets.add(
      Flexible(
        child: FractionallySizedBox(
          widthFactor: 0.95,
          child: _buildManga(manga),
        ),
      )
    );
  });

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: widgets,
  );
}

Widget _buildManga(Manga manga) {
  return Column(
    children: <Widget>[
      Container(
        margin: const EdgeInsets.only(bottom: 5.0),
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: CachedNetworkImage(
            imageUrl: manga.thumbnailUrl,
            placeholder: (context, url) => Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                height: 50.0,
                width: 50.0,
              )
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey,
              child: Icon(Icons.error),
            )
          ),
        ),
      ),
      SizedBox(
        width: double.infinity,
        height: 70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              manga.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              manga.lastUpdated,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    ],
  );
}
