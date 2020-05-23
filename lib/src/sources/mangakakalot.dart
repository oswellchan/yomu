import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart';

import '../database/db.dart';
import 'base.dart';

const maxRetry = 2;

class Mangakakalot extends Source {
  final name = 'mangakakalot';
  final url = 'https://mangakakalot.com/';

  Cursor getLatestMangas() {
    return MangakakalotLatestCursor();
  }

  Cursor getSearchResults(String search) {
    return MangakakalotSearchCursor(search);
  }

  Future<MangaDetails> getMangaDetails(String mangaUrl) async {
    if (mangaUrl.contains('https://manganelo.com/')) {
      final response = await _getNeloWebPage(mangaUrl);
      return await _parseNeloDetails(mangaUrl, response.body);
    }
    
    final response = await http.get(mangaUrl);
    return await _parseKakalotDetails(mangaUrl, response.body);
  }

  Future<MangaDetails> _parseNeloDetails(String mangaUrl, String body) async {
    var document = parse(body);
    var elements = document.getElementsByClassName('chapter-name text-nowrap');

    if (elements.isEmpty) {
      return MangaDetails('', <Chapter>[]);
    }

    var allRead = await DBHelper().getAllRead(name, mangaUrl);
    var allReadSet = <String>{};
    allReadSet.addAll(allRead);

    var results = <Chapter>[];
    elements.forEach((element) {
      var chapter = Chapter(
        element.attributes['href'],
        element.text
      );
      if (chapter != null) {
        if (allReadSet.contains(chapter.url)) {
          chapter.isRead = true;
        }
        results.add(chapter);
      }
    });

    return MangaDetails('', results);
  }

  Future<MangaDetails> _parseKakalotDetails(String mangaUrl, String body) async {
    var document = parse(body);
    var elements = document.getElementsByClassName('chapter-list');

    if (elements.isEmpty) {
      return MangaDetails('', <Chapter>[]);
    }

    var allRead = await DBHelper().getAllRead(name, mangaUrl);
    var allReadSet = <String>{};
    allReadSet.addAll(allRead);

    var results = <Chapter>[];
    elements[0].children.forEach((element) {
      var chapter = _parseLink(element);
      if (chapter != null) {
        if (allReadSet.contains(chapter.url)) {
          chapter.isRead = true;
        }
        results.add(chapter);
      }
    });

    return MangaDetails('', results);
  }

  Chapter _parseLink(dom.Element element) {
    var a = element.getElementsByTagName('a');
    if (a.isEmpty) {
      return null;
    }

    if (!a[0].attributes.containsKey('href')) {
      return null;
    }

    return Chapter(a[0].attributes['href'], a[0].text);
  }

  Future<MangaPages> getChapterPages(chptUrl) async {
    if (chptUrl.startsWith('https://manganelo.com/')) {
      final response = await _getNeloWebPage(chptUrl);
      var pages = _getNeloPages(response.body);
      var prevNextChapter = _getPrevNextNeloChapterUrls(response.body, chptUrl);
      return MangaPages(pages, prevNextChapter[0], prevNextChapter[1]);
    }

    final response = await http.get(chptUrl);
    var pages = _getKakalotPages(response.body);
    var prevNextChapter = _getPrevNextKakalotChapterUrls(response.body, chptUrl);

    return MangaPages(pages, prevNextChapter[0], prevNextChapter[1]);
  }

  List<String> _getNeloPages(String body) {
    var document = parse(body);

    var pages = document.getElementsByClassName('container-chapter-reader');

    var imgUrls = <String>[];
    pages[0].children.forEach((img) {
      var imgSrc = img.attributes['src'];
      if (imgSrc == null || !imgSrc.startsWith('https://') || !imgSrc.endsWith('.jpg')) {
        return;
      }
      imgUrls.add(imgSrc);
    });

    return imgUrls;
  }

  List<String> _getKakalotPages(String body) {
    var document = parse(body);

    var pages = document.getElementById('vungdoc');

    var imgUrls = <String>[];
    pages.children.forEach((img) {
      var imgSrc = img.attributes['src'];
      if (imgSrc == null || !imgSrc.startsWith('https://') || !imgSrc.endsWith('.jpg')) {
        return;
      }
      imgUrls.add(imgSrc);
    });

    return imgUrls;
  }

  List<String> _getPrevNextNeloChapterUrls(String body, chptUrl) {
    var document = parse(body);
    var prevE = document.getElementsByClassName('navi-change-chapter-btn-prev a-h');
    var nextE = document.getElementsByClassName('navi-change-chapter-btn-next a-h');

    return [
      prevE.isEmpty ? '' : prevE[0].attributes['href'],
      nextE.isEmpty ? '' : nextE[0].attributes['href'],
    ];
  }

  List<String> _getPrevNextKakalotChapterUrls(String body, chptUrl) {
    var document = parse(body);
    var navigation = document.getElementsByClassName('btn-navigation-chap');
    // kakalot messes up the class names
    var prevE = navigation[0].getElementsByClassName('next');
    var nextE = navigation[0].getElementsByClassName('back');

    return [
      prevE.isEmpty ? '' : prevE[0].attributes['href'],
      nextE.isEmpty ? '' : nextE[0].attributes['href'],
    ];
  }
}

class MangakakalotLatestCursor extends Cursor {
  Set<Manga> _oldResult;
  num _index;

  MangakakalotLatestCursor() {
    _index = 1;
  }

  Future<List<Manga>> getNext() async {
    var url = 'https://mangakakalot.com/manga_list?type=latest&category=all&state=all&page=$_index';
    final response = await http.get(url);
    var mangas = _getMangas(response.body);

    _index += 1;

    return mangas;
  }

  List<Manga> _getMangas(String body) {
    var document = parse(body);
    var elements = document.getElementsByClassName('list-truyen-item-wrap');

    if (elements.isEmpty) {
      return <Manga>[];
    }

    var results = <Manga>[];
    elements.forEach((element) {
      var manga = _parseManga(element);
      if (manga != null) {
        results.add(manga); 
      }
    });

    return results;
  }

  Manga _parseManga(dom.Element element) {
    var manga = Manga();
    var elements = element.children;
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

    var splitHref = manga.mangaUrl.split('/manga/');

    manga.id = splitHref.last;
    manga.name = eCover.attributes['title'];

    elements = eCover.children;
    if (elements.isEmpty) {
      return null;
    }
    var eImg = elements[0];
    manga.thumbnailUrl = eImg.attributes['src'];
    manga.lastUpdated = '';

    return manga;
  }
}

class MangakakalotSearchCursor extends MangakakalotLatestCursor {
  String searchTerm;

  MangakakalotSearchCursor(String searchTerm) {
    this.searchTerm = searchTerm.replaceAll(' ', '_');
  }

  Future<List<Manga>> getNext() async {
    var url = 'https://mangakakalot.com/search/$searchTerm?page=$_index';
    url = Uri.encodeFull(url);
    final response = await http.get(url);
    var mangas = _getMangas(response.body);

    _index += 1;

    return mangas;
  }

  List<Manga> _getMangas(String body) {
    var document = parse(body);
    var elements = document.getElementsByClassName('story_item');

    if (elements.isEmpty) {
      return <Manga>[];
    }

    var results = <Manga>[];
    elements.forEach((element) {
      var manga = _parseManga(element);
      if (manga != null) {
        results.add(manga); 
      }
    });

    return results;
  }

  Manga _parseManga(dom.Element element) {
    var manga = Manga();
    var elements = element.children;
    if (elements.isEmpty) {
      return null;
    }
    var eMangaUrl = elements[0];

    if (!eMangaUrl.attributes.containsKey('href')) {
      return null;
    }

    manga.mangaUrl = eMangaUrl.attributes['href'];

    var splitHref = manga.mangaUrl.split('/manga/');

    manga.id = splitHref.last;

    var eCover = eMangaUrl.children[0];
    manga.thumbnailUrl = eCover.attributes['src'];

    var eName = element.getElementsByClassName('story_name');
    manga.name = eName[0].children[0].text;
    manga.lastUpdated = '';

    return manga;
  }
}

Future<Response> _getNeloWebPage(String url) async {
  var response = await http.get(url);
  var retryCount = 0;

  while (_isPHPError(response.body) && retryCount < maxRetry) {
    debugPrint(response.body, wrapWidth: 1024);
    response = await http.get(url);
    retryCount += 1;
  }

  return response;
}

bool _isPHPError(String body) {
    var exp = new RegExp(r'<h4>A PHP Error was encountered</h4>');

    return !(exp.firstMatch(body) == null);
}
