import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import '../database/db.dart';
import 'base.dart';

class MangaTown extends Source {
  final name = 'MangaTown';
  final url = 'https://www.mangatown.com/';

  Cursor getLatestMangas() {
    return MangaTownLatestCursor();
  }

  Cursor getSearchResults(String search) {
    return MangaTownSearchCursor(search);
  }

  Future<MangaDetails> getMangaDetails(String mangaUrl) async {
    final url = '${this.url}$mangaUrl';
    final response = await http.get(url);

    var document = parse(response.body);
    var elements = document.getElementsByClassName('chapter_list');

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

    var name = a[0].text;
    var words = name.split(' ');
    var chapterNum = '';
    for (var i = words.length - 1; i >= 0; i--) {
      if (words[i] != '') {
        chapterNum = words[i];
        break;
      }
    }

    return Chapter(a[0].attributes['href'], 'Chapter $chapterNum');
  }

  Future<MangaPages> getChapterPages(chptUrl) async {
    final response = await http.get(this.url + chptUrl);

    var maxPages = _getNumberOfPages(response.body, chptUrl);
    var pages = await _getPages(chptUrl, maxPages);

    var prevNextChapter = _getPrevNextChapterUrls(response.body, chptUrl);

    return MangaPages(pages, prevNextChapter[0], prevNextChapter[1], '');
  }

  num _getNumberOfPages(String body, chptUrl) {
    var exp = new RegExp('option value="$chptUrl([0-9]+).html');
    var matches = exp.allMatches(body);

    var maxPages = 0;
    matches.forEach((match) {
      var pageNoStr = match.group(1);
      try {
        var pageNoNum = int.parse(pageNoStr);
        maxPages = max(maxPages, pageNoNum);
      } catch (e) {
        print(e);
      }
    });

    return maxPages;
  }

  Future<List<String>> _getPages(String chptUrl, num maxPages) async {
    var futures = <Future<http.Response>>[];
    for (var i = 0; i < maxPages; i++) {
      futures.add(http.get('$url$chptUrl${i + 1}.html'));
    }

    var results = await Future.wait(futures);

    var imgUrls = <String>[];
    results.forEach((response) {
      var body = response.body;
      var exp = new RegExp(r'//l.mangatown.com/store/manga/.*?.jpg');
      var match = exp.firstMatch(body);

      var pageUrl = match.group(0);
      imgUrls.add('http:$pageUrl');
    });

    return imgUrls;
  }

  List<String> _getPrevNextChapterUrls(String body, chptUrl) {
    var document = parse(body);
    var chapterList = document.getElementById('top_chapter_list');
    var prevChapter = '';
    var nextChapter = '';
    var options = chapterList.children;

    for (var i = 0; i < options.length; i++) {
      var option = options[i];
      var val = option.attributes['value'];
      if (val == chptUrl) {
        if (i + 1 < options.length) {
          nextChapter = options[i + 1].attributes['value'];
        }
        break;
      }
      prevChapter = val;
    }

    return [prevChapter, nextChapter];
  }

  @override
  Future<List> getRecentMangas(int n) {
    // TODO: implement getRecentMangas
    throw UnimplementedError();
  }
}

class MangaTownLatestCursor extends Cursor {
  num _index;

  MangaTownLatestCursor() {
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

  Manga _parseManga(dom.Element element) {
    var manga = Manga();
    var elements = element.getElementsByClassName('manga_cover');
    if (elements.isEmpty) {
      return null;
    }
    var eCover = elements[0];
    if (!eCover.attributes.containsKey('href') ||
        !eCover.attributes.containsKey('title')) {
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

class MangaTownSearchCursor extends MangaTownLatestCursor {
  String searchTerm;

  MangaTownSearchCursor(String searchTerm) {
    this.searchTerm = searchTerm;
  }

  Future<List<Manga>> getNext() async {
    var url = 'https://www.mangatown.com/search?page=$_index&name=$searchTerm';
    url = Uri.encodeFull(url);
    final response = await http.get(url);
    var mangas = _getMangas(response.body);

    _index += 1;

    return mangas;
  }
}
