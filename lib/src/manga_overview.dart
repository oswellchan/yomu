import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'sources/base.dart';
import 'sources/mangatown.dart';


class MangaOverviewState extends State<MangaOverview> {

  @override
  Widget build(BuildContext context) {
    final Manga manga = ModalRoute.of(context).settings.arguments;

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Container(
          color: CupertinoColors.black,
          child: Column(
            children: <Widget>[
              NavBar(),
              MangaDetail(manga: manga),
            ],
          )
        ),
      )
    );
  }
}

class MangaOverview extends StatefulWidget {
  @override
  MangaOverviewState createState() => MangaOverviewState();
}

class NavBar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CupertinoButton(
          onPressed: () {
            Navigator.of(context).pop(context);
          },
          child: Icon(
            CupertinoIcons.clear_thick,
            color: CupertinoColors.white,
          ),
        ),
      ]
    );
  }
}

class MangaDetail extends StatelessWidget {

  MangaDetail({
    @required this.manga,
  });

  final Manga manga;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CachedNetworkImage(
          imageUrl: manga.thumbnailUrl,
          placeholder: (context, url) => Center(
            child: SizedBox(
              child: CupertinoActivityIndicator(),
              height:70.0,
              width: 70.0,
            )
          ),
          errorWidget: (context, url, error) => Container(
            width: 200,
            height: 310,
            color: CupertinoColors.systemGrey,
            child: Icon(Icons.error),
          )
        ),
        SizedBox(height: 20),
        FractionallySizedBox(
          widthFactor: 0.7,
          child: Text(
            manga.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}