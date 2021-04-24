import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../database/db.dart';
import '../manga_overview.dart';
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
  String _prevChapter = '';
  String _currChapter = '';
  String _nextChapter = '';

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
    )));
  }

  Widget _buildPages(List<String> images) {
    return ListView.builder(itemBuilder: (BuildContext _context, int i) {
      if (i >= _images.length) {
        if (_nextChapter != '' && !_isFetching) {
          _fetchPages(_nextChapter);
          return Spinner();
        }
        return null;
      }

      return _buildPage(images[i], _manga);
    });
  }

  void _fetchPages(String url) async {
    if (_chapters.contains(url) || url == null || url == '') {
      return;
    }

    _isFetching = true;
    var chpt = await _source.getChapterPages(url);

    if (_manga != '')
      DBHelper().saveRead(_source.name, _manga, url, chpt.title);

    if (!mounted) return;
    setState(() {
      _chapters.add(url);
      _prevChapter = chpt.prevChapterUrl;
      _currChapter = url;
      _nextChapter = chpt.nextChapterUrl;
      _isFetching = false;

      if (_currChapter == chpt.nextChapterUrl) {
        // append at the back
      } else {
        _images.addAll(chpt.pages);
      }
    });
  }
}

class Reader extends StatefulWidget {
  @override
  ReaderState createState() => ReaderState();
}

class MangaPageState extends State<MangaPage> {
  int reloadCount = 0;
  int oldReloadCount = 0;

  @override
  Widget build(BuildContext context) {
    var reload = GestureDetector(
        child: SizedBox(
            child: Icon(
              CupertinoIcons.refresh,
              color: CupertinoColors.white,
            ),
            width: 50),
        onTap: () {
          setState(() {
            reloadCount += 1;
          });
        });

    var cacheKey = reloadCount.toString() + widget.pageUrl;

    Widget child;

    if (reloadCount == oldReloadCount) {
      child = CachedNetworkImage(
          httpHeaders: {'referer': widget.mangaUrl},
          imageUrl: widget.pageUrl,
          placeholder: (context, url) => Spinner(),
          errorWidget: (context, url, error) => reload);
    } else {
      child = Spinner();
      _reloadImage(widget.pageUrl, cacheKey);
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: child,
    );
  }

  void _reloadImage(String url, String cacheKey) async {
    await CachedNetworkImage.evictFromCache(url);
    setState(() {
      oldReloadCount = reloadCount;
    });
  }
}

class MangaPage extends StatefulWidget {
  final String pageUrl;
  final String mangaUrl;

  MangaPage({@required this.pageUrl, this.mangaUrl});

  @override
  MangaPageState createState() => MangaPageState();
}

Widget _buildPage(String pageUrl, String mangaUrl) {
  return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: MangaPage(pageUrl: pageUrl, mangaUrl: mangaUrl));
}
