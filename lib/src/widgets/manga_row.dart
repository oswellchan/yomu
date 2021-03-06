import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../sources/base.dart';
import '../widgets/spinner.dart';

class MangaRow extends StatelessWidget {
  MangaRow({
    @required this.mangas,
  });

  final List<Manga> mangas;

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[];
    mangas.forEach((manga) {
      Widget widget = Container();

      if (manga != null) {
        widget = MangaTile(
            thumbnailUrl: manga.thumbnailUrl,
            name: manga.name,
            lastUpdated: manga.lastUpdated,
            referrer: manga.mangaUrl,
            onPress: () {
              Navigator.of(context, rootNavigator: true)
                  .pushNamed('/manga', arguments: manga);
            });
      }

      widgets.add(Flexible(
        child: FractionallySizedBox(widthFactor: 0.95, child: widget),
      ));
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
    this.referrer,
    this.onPress,
  });

  final String thumbnailUrl;
  final String name;
  final String lastUpdated;
  final String referrer;
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
            httpHeaders: {'referer': referrer},
            placeholder: (context, url) => Center(
                  child: Spinner(),
                ),
            errorWidget: (context, url, error) => Container(
                  color: CupertinoColors.systemGrey,
                  child: Icon(Icons.error),
                )),
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

    return GestureDetector(
        child: Column(
          children: <Widget>[
            cover,
            text,
          ],
        ),
        onTap: onPress);
  }
}
