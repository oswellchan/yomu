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
              Expanded(
                child: MangaDetail(manga: manga)
              ),
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
          child: Chapters(mangaUrl: manga.mangaUrl),
        ),
      ],
    );
  }
}

class ChaptersState extends State<Chapters> {
  final MangaTown _source = MangaTown();
  List<Link> _chapters = <Link>[];
  bool _notFetching = true;

  final String mangaUrl;

  ChaptersState({
    @required this.mangaUrl,
  });

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
            return ChapterTile(
              name: 'Chapter ${length - i}',
              url: _chapters[length - i - 1].url,
            );
          }
        )
      ),
    );
  }

  void _fetchMangaDetails() async {
    var details = await _source.getMangaDetails(mangaUrl);
    if (details.chapters.isNotEmpty) {
      setState(() {
        _chapters = details.chapters.reversed.toList();
      });
    }
  }
}

class Chapters extends StatefulWidget {
  final String mangaUrl;

  Chapters({
    @required this.mangaUrl,
  });

  @override
  ChaptersState createState() => ChaptersState(mangaUrl: mangaUrl);
}

class ChapterTile extends StatelessWidget {

  final String url;
  final String name;

  ChapterTile({
    @required this.url,
    @required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector (
      child: Container(
        height: 30,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        )
      ),
      onTap: () {
        Navigator.of(context).pushNamed(
          '/read',
          arguments: this.url,
        );
      }
    );
  }
}
