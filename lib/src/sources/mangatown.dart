import 'dart:math';

// import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'base.dart';

class MangaTown extends Source {
  final url = 'https://www.mangatown.com/';

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
      return List<String>();
    }

    var preUrl = match.group(1);
    var imgUrls = List<String>();
    for(var i = 0; i < maxPages; i++) {
      var number = (startingPage + i).toString().padLeft(3, '0');
      imgUrls.add('http:$preUrl$number.jpg');
    }

    return imgUrls;
  }
}
