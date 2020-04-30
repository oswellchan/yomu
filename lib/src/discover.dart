import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'sources/base.dart';
import 'sources/mangatown.dart';


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

class MangaRow extends StatelessWidget {

  MangaRow({
    @required this.mangas,
  });

  final List<Manga> mangas;

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[];
    mangas.forEach((manga) {
      widgets.add(
        Flexible(
          child: FractionallySizedBox(
            widthFactor: 0.95,
            child: MangaTile(
              thumbnailUrl: manga.thumbnailUrl,
              name: manga.name,
              lastUpdated: manga.lastUpdated,
              onPress: () {
                Navigator.of(context).pushNamed(
                  '/manga',
                  arguments: manga
                );
              }
            ),
          ),
        )
      );
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: widgets,
    );
  }
}

class MangaTile extends StatelessWidget {

  MangaTile({
    @required this.thumbnailUrl,
    @required this.name,
    @required this.lastUpdated,
    this.onPress,
  });

  final String thumbnailUrl;
  final String name;
  final String lastUpdated;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    var cover = Container(
      margin: const EdgeInsets.only(bottom: 5.0),
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: CachedNetworkImage(
          imageUrl: thumbnailUrl,
          placeholder: (context, url) => Center(
            child: SizedBox(
              child: CupertinoActivityIndicator(),
              height:70.0,
              width: 70.0,
            )
          ),
          errorWidget: (context, url, error) => Container(
            color: CupertinoColors.systemGrey,
            child: Icon(Icons.error),
          )
        ),
      ),
    );

    var text = SizedBox(
      width: double.infinity,
      height: 70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            lastUpdated,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      ),
    );

    return GestureDetector (
      child: Column(
        children: <Widget>[
          cover,
          text,
        ],
      ),
      onTap: onPress
    );
  }
}
