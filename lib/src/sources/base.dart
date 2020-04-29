abstract class Source {
  Manga getMangaDetails(String id);
  Future<List<String>> getChapterPages(String id, num chapter);
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

abstract class Cursor {
  Future<List<Manga>> getNext();
}
