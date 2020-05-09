import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'reader/arguments.dart';
import 'sources/base.dart';
import 'sources/mangatown.dart';


class MangaOverviewState extends State<MangaOverview> with RouteAware {

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
              Expanded(
                child: MangaDetail(
                  manga: manga,
                  routeObserver: widget.routeObserver,
                ),
              ),
            ],
          )
        ),
      )
    );
  }
}

class MangaOverview extends StatefulWidget {

  final RouteObserver<PageRoute> routeObserver;

  MangaOverview({
    @required this.routeObserver
  });

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
            Navigator.of(context, rootNavigator: true).pop(context);
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

  final Manga manga;
  final RouteObserver<PageRoute> routeObserver;

  MangaDetail({
    @required this.manga,
    @required this.routeObserver,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 200,
          child: CachedNetworkImage(
            imageUrl: manga.thumbnailUrl,
            placeholder: (context, url) => Center(
              child: SizedBox(
                child: CupertinoActivityIndicator(),
                height:70.0,
                width: 70.0,
              )
            ),
            errorWidget: (context, url, error) => Container(
              width: 150,
              height: 200,
              color: CupertinoColors.systemGrey,
              child: Icon(Icons.error),
            )
          ),
        ),
        SizedBox(height: 20),
        FractionallySizedBox(
          widthFactor: 0.7,
          child: Text(
            manga.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: Chapters(
            mangaUrl: manga.mangaUrl,
            routeObserver: routeObserver,
          ),
        ),
      ],
    );
  }
}

class ChaptersState extends State<Chapters> with RouteAware {
  final MangaTown _source = MangaTown();
  List<Chapter> _chapters = <Chapter>[];
  bool _notFetching = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    widget.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _fetchMangaDetails();
  }

  @override
  Widget build(BuildContext context) {

    if (_notFetching) {
      _fetchMangaDetails();
      _notFetching = false;
    }

    var length = _chapters.length;

    return Container(
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: ListView.separated(
          itemCount: _chapters.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              color: CupertinoColors.systemGrey.withOpacity(0.5),
            );
          },
          itemBuilder: (BuildContext _context, int i) {
            var chapter = _chapters[length - i - 1];
            return ChapterTile(
              chapter: chapter,
              manga: widget.mangaUrl,
            );
          }
        )
      ),
    );
  }

  void _fetchMangaDetails() async {
    var details = await _source.getMangaDetails(widget.mangaUrl);

    if (details.chapters.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _chapters = details.chapters.reversed.toList();
      });
    }
  }
}

class Chapters extends StatefulWidget {

  final String mangaUrl;
  final RouteObserver<PageRoute> routeObserver;

  Chapters({
    @required this.mangaUrl,
    @required this.routeObserver,
  });

  @override
  ChaptersState createState() => ChaptersState();
}

class ChapterTileState extends State<ChapterTile> {

  @override
  Widget build(BuildContext context) {
    var textColour = widget.chapter.isRead ? CupertinoColors.systemGrey : null;

    return GestureDetector (
      child: Container(
        height: 30,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.chapter.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColour,
              fontSize: 16,
            ),
          ),
        )
      ),
      onTap: () {
        Navigator.of(context, rootNavigator: true).pushNamed(
          '/read',
          arguments: ReaderArguments(
            widget.manga,
            widget.chapter.url
          ),
        );
      }
    );
  }
}

class ChapterTile extends StatefulWidget {

  final Chapter chapter;
  final String manga;

  ChapterTile({
    @required this.chapter,
    @required this.manga,
  });

  @override
  ChapterTileState createState() => ChapterTileState();
}