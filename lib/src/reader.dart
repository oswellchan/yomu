import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'manga_overview.dart';
import 'sources/mangatown.dart';


class ReaderState extends State<Reader> {
  final MangaTown _source = MangaTown();
  final List<String> _images = <String>[];
  final Set<String> _chapters = <String>{};
  
  bool _isFetching = false;
  String _prevChapter;
  String _currChapter;
  String _nextChapter;


  @override
  Widget build(BuildContext context) {
    var chapterUrl = ModalRoute.of(context).settings.arguments;
    
    if (!_chapters.contains(chapterUrl)) {
      _nextChapter = chapterUrl;
    }

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            NavBar(),
            Expanded(
              child: _buildPages(this._images),
            )
          ],
        )
      )
    );
  }

  Widget _buildPages(List<String> images) {
    return ListView.builder(
      itemBuilder: (BuildContext _context, int i) {
        if (i >= _images.length) {
          if (!_isFetching) {
            _fetchPages(_nextChapter);
          }
          return null;
        }

        return _buildPage(images[i]);
      }
    );
  }

  void _fetchPages(String url) async {
    if (_chapters.contains(url)) {
      return;
    }

    _isFetching = true;
    var chpt = await _source.getChapterPages(url);
    if (_currChapter == chpt.nextChapterUrl) {
      // append at the back
    } else {
      _images.addAll(chpt.pages);
    }

    setState(() {
      _chapters.add(url);
      _prevChapter = chpt.prevChapterUrl;
      _currChapter = url;
      _nextChapter = chpt.nextChapterUrl;
      _isFetching = false;
    });
  }
}

class Reader extends StatefulWidget {
  @override
  ReaderState createState() => ReaderState();
}

Widget _buildPage(String pageUrl) {
  return Container(
    padding: const EdgeInsets.only(bottom: 10),
    child: CachedNetworkImage(
      imageUrl: pageUrl,
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
  );
}
