import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'sources/mangatown.dart';


class ReaderState extends State<Reader> {
  final MangaTown _source = MangaTown();
  final List<String> _images = <String>[];
  bool loadNewChapter = true;

  @override
  Widget build(BuildContext context) {
    if (!this.loadNewChapter) {
      return _buildPages(this._images);
    }

    var future = FutureBuilder<List<String>>(
      future: _source.getChapterPages('tales_of_demons_and_gods', 270),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasData) {
          _images.addAll(snapshot.data);
        }
        return _buildPages(this._images);
      },
    );
    this.loadNewChapter = false;
    return future;
  }
}

class Reader extends StatefulWidget {
  @override
  ReaderState createState() => ReaderState();
}

Widget _buildPages(List<String> images) {
  return ListView.builder(
    itemCount: images.length,
    itemBuilder: (BuildContext _context, int i) {
      return _buildPage(images[i]);
    }
  );
}

Widget _buildPage(String pageUrl) {
  return CachedNetworkImage(
        imageUrl: pageUrl,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
  );
}
