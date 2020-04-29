import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'sources/base.dart';
import 'sources/mangatown.dart';


class MangaOverviewState extends State<MangaOverview> {

  @override
  Widget build(BuildContext context) {
    final Manga manga = ModalRoute.of(context).settings.arguments;
    print(manga);
    return Container(
      color: Colors.green,
      child: Text('hello world'),
    );
  }
}

class MangaOverview extends StatefulWidget {
  @override
  MangaOverviewState createState() => MangaOverviewState();
}
