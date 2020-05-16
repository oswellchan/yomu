import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../database/db.dart';
import '../manga_overview.dart';
import '../sources/mangatown.dart';
import '../sources/mangakakalot.dart';
import '../widgets/spinner.dart';
import '../widgets/zoomable_widget.dart';
import 'arguments.dart';


class ReaderState extends State<Reader> {
  final Mangakakalot _source = Mangakakalot();
  final List<String> _images = <String>[];
  final Set<String> _chapters = <String>{};
  String _manga;
  
  bool _isFetching = false;
  String _prevChapter;
  String _currChapter;
  String _nextChapter;

  @override
  Widget build(BuildContext context) {
    ReaderArguments args = ModalRoute.of(context).settings.arguments;
    _manga = args.mangaUrl;

    var chapterUrl = args.chapterUrl;
    if (!_chapters.contains(chapterUrl)) {
      _nextChapter = chapterUrl;
    }

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            NavBar(),
            Expanded(
              child: ZoomableWidget(
                child: _buildPages(this._images),
                onInteract: null,
              ),
            ),
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
            return Spinner();
          }
          return null;
        }

        return _buildPage(images[i], _manga);
      }
    );
  }

  void _fetchPages(String url) async {
    if (_chapters.contains(url) || url == null) {
      return;
    }

    _isFetching = true;
    var chpt = await _source.getChapterPages(url);

    if (_manga != '') DBHelper().saveRead(
      _source.name, _manga, url
    );

    if (_currChapter == chpt.nextChapterUrl) {
      // append at the back
    } else {
      _images.addAll(chpt.pages);
    }

    if (!mounted) return;
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

Widget _buildPage(String pageUrl, String mangaUrl) {
  return Container(
    padding: const EdgeInsets.only(bottom: 10),
    child: CachedNetworkImage(
      httpHeaders: {'referer': mangaUrl},
      imageUrl: pageUrl,
      placeholder: (context, url) => Center(
        child: Spinner(),
      ),
      errorWidget: (context, url, error) => Container(
        color: CupertinoColors.systemGrey,
        child: Icon(Icons.error),
      )
    ),
  );
}
