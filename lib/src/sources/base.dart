abstract class Source {
  Manga getMangaDetails(String id);
  Future<List<String>> getChapterPages(String id, num chapter);
}

class Manga {
  String id;
  String name;
  String thumbnailUrl;
}
