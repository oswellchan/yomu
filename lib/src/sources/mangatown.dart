import 'dart:math';

// import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'base.dart';

class MangaTown extends Source {
  final url = 'https://www.mangatown.com/';

  MangaTownCursor getLatestMangas() {
    return MangaTownCursor();
  }

  Manga getMangaDetails(String id) {
    return Manga();
  }

  Future<List<String>> getChapterPages(String id, num chapter) async {
    final chptUrl = '${this.url}/manga/$id/c$chapter/';
    final response = await http.get(chptUrl);

    var maxPages = _getNumberOfPages(response.body, id, chapter);

    return _getPages(response.body, maxPages);
  }

  num _getNumberOfPages(String body, String id, num chapter) {
    var exp = new RegExp('option value="/manga/$id/c$chapter/([0-9]+).html');
    var matches = exp.allMatches(body);

    var maxPages = 0;
    matches.forEach((match) {
      var pageNoStr = match.group(1);
      try {
        var pageNoNum = int.parse(pageNoStr);
        maxPages = max(maxPages, pageNoNum);
      } catch(e) {
        print(e);
      }
    });

    return maxPages;
  }

  List<String> _getPages(String body, num maxPages) {
    var exp = new RegExp(r'//l.mangatown.com/store/manga/.*?.jpg');
    var match = exp.firstMatch(body);

    var url = match.group(0);
    exp = new RegExp(r'(.*)([0-9]{3}).jpg$');
    match = exp.firstMatch(url);

    var startingPage = 0;
    try {
      var val = double.parse('0.${match.group(2)}1');
      startingPage = (val * 100).round();
    } catch(e) {
      return <String>[];
    }

    var preUrl = match.group(1);
    var imgUrls = <String>[];
    for(var i = 0; i < maxPages; i++) {
      var number = (startingPage + i).toString().padLeft(3, '0');
      imgUrls.add('http:$preUrl$number.jpg');
    }

    return imgUrls;
  }
}

class MangaTownCursor extends Cursor {
  Set<Manga> _oldResult;
  num _index;

  MangaTownCursor() {
    _index = 1;
  }

  Future<List<Manga>> getNext() async {
    var url = 'https://www.mangatown.com/latest/${this._index}.htm';
    final response = await http.get(url);
    var mangas = _getMangas(response.body);

    _index += 1;

    return mangas;
  }

  List<Manga> _getMangas(String body) {
    var document = parse(body);
    var elements = document.getElementsByClassName('manga_pic_list');

    if (elements.isEmpty) {
      return <Manga>[];
    }

    var results = <Manga>[];
    elements[0].children.forEach((element) {
      var manga = _parseManga(element);
      if (manga != null) {
        results.add(manga); 
      }
    });

    return results;
  }

  Manga _parseManga(Element element) {
    var manga = Manga();
    var elements = element.getElementsByClassName('manga_cover');
    if (elements.isEmpty) {
      return null;
    }
    var eCover = elements[0];
    if (!eCover.attributes.containsKey('href') ||
      !eCover.attributes.containsKey('title')
    ) {
      return null;
    }

    manga.mangaUrl = eCover.attributes['href'];

    var splitHref = manga.mangaUrl.split('/');
    if (splitHref.length != 4) {
      return null;
    }

    manga.id = splitHref[2];
    manga.name = eCover.attributes['title'];

    elements = eCover.getElementsByTagName('img');
    if (elements.isEmpty) {
      return null;
    }
    var eImg = elements[0];
    manga.thumbnailUrl = eImg.attributes['src'];

    var eLast = element.children.last;
    manga.lastUpdated = eLast.text;

    return manga;
  }
}
