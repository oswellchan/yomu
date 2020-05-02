abstract class Source {
  Future<MangaDetails> getMangaDetails(String id);
  Future<MangaPages> getChapterPages(String chptUrl);
}

class Manga {
  String id;
  String name;
  String thumbnailUrl;
  String mangaUrl;
  String lastUpdated;

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
  List<Link> chapters;

  MangaDetails(this.summary, this.chapters);
}

class Link {
  String url;
  String text;

  Link(this.url, this.text);
}

class MangaPages {
  List<String> pages;
  String nextChapterUrl;
  String prevChapterUrl;

  MangaPages(this.pages, this.prevChapterUrl, this.nextChapterUrl);
}

abstract class Cursor {
  Future<List<Manga>> getNext();
}