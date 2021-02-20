abstract class Source {
  Future<MangaDetails> getMangaDetails(String id);
  Future<MangaPages> getChapterPages(String chptUrl);
  Future<List> getRecentMangas(int n);
  Cursor getLatestMangas();
  Cursor getSearchResults(String search);
}

class Manga {
  String id;
  String name;
  String thumbnailUrl;
  String mangaUrl;
  String lastUpdated;

  Manga(
      {String id,
      String name,
      String thumbnailUrl,
      String mangaUrl,
      String lastUpdated})
      : this.id = id,
        this.name = name,
        this.thumbnailUrl = thumbnailUrl,
        this.mangaUrl = mangaUrl,
        this.lastUpdated = lastUpdated;

  bool operator ==(o) {
    return o is Manga && this.id == o.id;
  }

  int get hashCode {
    return this.id.hashCode;
  }

  String toString() {
    return '$id, $name, $thumbnailUrl, $lastUpdated';
  }
}

class MangaDetails {
  String summary;
  List<Chapter> chapters;

  MangaDetails(this.summary, this.chapters);
}

class Chapter {
  String url;
  String text;
  bool isRead = false;
  int lastRead;

  Chapter(this.url, this.text);

  Chapter.withLastRead(this.url, this.text, this.lastRead);
}

class MangaPages {
  List<String> pages;
  String nextChapterUrl;
  String prevChapterUrl;
  String title;

  MangaPages(this.pages, this.prevChapterUrl, this.nextChapterUrl, this.title);
}

abstract class Cursor {
  Future<List<Manga>> getNext();
}
