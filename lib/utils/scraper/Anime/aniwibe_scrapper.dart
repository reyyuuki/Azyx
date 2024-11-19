import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'dart:developer';

Future<Map<String, dynamic>?> scrape() async {
  try {
    const url = "https://anivibe.net/series/naruto-shippuden";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = html.parse(response.body);

      final title = document.querySelector(".infox h1")?.text.trim();
      final episodes = [];
      final episodesData = document.querySelectorAll(".eplister li");
      for (var episode in episodesData) {
        final id = episode.querySelector("a")?.attributes['href'];
        final number = episode.querySelector(".epl-num")?.text.trim();
        final title = episode.querySelector('epl-title')?.text.trim();
        log(title.toString());
        episodes.add({"title": title, "number": number, "episodeId": id});
      }

      final data = {
        "episodes": episodes,
        "name": title,
        "totalEpisodes": episodes.length
      };
    log(data.toString());
      return data;
    }
  } catch (e) {
    log("error while scrapping aniwibe: $e");
  }
}

Future<List<dynamic>> scrapeSearchdata() async{
  try{
    const url = "https://anivibe.net/search.html?keyword=naruto";
    final response = await  http.get(Uri.parse(url));
final searchData = [];
    if(response.statusCode == 200){
      final document = html.parse(response.body);
      final searchElements = document.querySelectorAll(".listupd .bs");
      
      for(var searchItem in searchElements){
        final id = searchItem.querySelector(".bsx a")?.attributes['href'];
        final title = searchItem.querySelector(".bsx a .limit img")?.attributes['title'];
        final image = searchItem.querySelector(".bsx a .limit img")?.attributes['src'];

        searchData.add({
          "id": id,
          "name": title,
          "image": image,
        });
          log(searchData.toString());
      }
    
      return searchData;
    }
  }catch(e){
    log("Error while searching data: $e");
  }
  return [];
}
