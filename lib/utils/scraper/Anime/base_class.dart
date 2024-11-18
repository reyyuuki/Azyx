abstract class EXtractAnimes{
  String get sourceName;
  String get url;
  
  Future<Map<String, dynamic>> scrapeAnimeEpisodes(String animeId);
  Future<dynamic> fetchStreamingLinksAniwatch(
    String id, String server, String category);
    Future<List<Map<String, dynamic>>> scrapeAnimeSearch(String query,
    {int page = 1});
}