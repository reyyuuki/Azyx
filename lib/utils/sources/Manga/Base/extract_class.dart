abstract class ExtractClass {

  String? get url;
  String get sourceVersion;
  String get sourceName;


  Future<dynamic> fetchChapters(String mangaId);
  Future<dynamic> fetchSearchsManga(String name);
  Future<dynamic> fetchPages(String link);
}
  