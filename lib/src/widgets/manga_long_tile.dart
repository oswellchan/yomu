import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:yomu/src/reader/arguments.dart';
import 'package:yomu/src/sources/base.dart';

import '../widgets/spinner.dart';

class MangaLongTile extends StatelessWidget {
  MangaLongTile({
    @required this.manga,
    @required this.chapter,
  });

  final Manga manga;
  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    var cover = Container(
      child: SizedBox(
        width: 120,
        child: CachedNetworkImage(
            imageUrl: manga.thumbnailUrl,
            placeholder: (context, url) => Center(
                  child: Spinner(),
                ),
            errorWidget: (context, url, error) => Container(
                  color: CupertinoColors.systemGrey,
                  child: Icon(Icons.error),
                )),
      ),
    );

    var text = Expanded(
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  manga.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  chapter.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10),
                Text(
                  formatTime(chapter.lastRead),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: CupertinoColors.systemGrey),
                ),
              ],
            )));

    var info = GestureDetector(
        child: SizedBox(
            child: Icon(
              CupertinoIcons.info_circle,
              color: CupertinoColors.white,
            ),
            width: 50),
        onTap: () {
          Navigator.of(context, rootNavigator: true)
              .pushNamed('/manga', arguments: manga);
        });

    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
              child: Row(children: <Widget>[
                cover,
                text,
              ]),
              onTap: () {
                Navigator.of(context, rootNavigator: true).pushNamed(
                  '/read',
                  arguments: ReaderArguments(manga.mangaUrl, chapter.url),
                );
              }),
        ),
        info
      ],
    );
  }
}
