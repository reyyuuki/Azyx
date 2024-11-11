import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> getMangaDetails(String mangaId) async {
  const String url = 'https://graphql.anilist.co';

  const String query = '''
    query (\$id: Int) {
      Media(id: \$id, type: MANGA) {
        title {
          romaji
          english
          native
        }
        coverImage {
          extraLarge
          large
        }
        bannerImage
        description(asHtml: false)
        genres
        averageScore
        popularity
        status
        chapters
        volumes
        updatedAt
        staff {
          edges {
            node {
              name {
                full
              }
            }
            role
          }
        }
      }
    }
  ''';

  final response = await http.post(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
    body: json.encode({
      "query": query,
      "variables": {"id": int.parse(mangaId)},
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final manga = data['data']['Media'];
    
    // Format the manga details
    final formattedDetails = {
      'coverImage': manga['bannerImage'] ??  manga['coverImage']['extraLarge'],
      'poster': manga['coverImage']['large'],
      'id': mangaId,
      'name': manga['title']['english'] ?? manga['title']['romaji'] ?? manga['title']['native'] ?? 'N/A',
      'jname': manga['title']['native'] ?? 'N/A',
      'authors': manga['staff']['edges']
          .map((edge) => edge['node']['name']['full'])
          .toList(),
      'status': manga['status'] ?? 'N/A',
      'updated': DateTime.fromMillisecondsSinceEpoch((manga['updatedAt'] ?? 0) * 1000).toString(),
      'view': (manga['popularity'] ?? 'N/A').toString(),
      'genres': manga['genres'] ?? [],
      'description': manga['description'] ?? 'No description available.',
    };
    
    return formattedDetails;
  } else {
    log("Error: ${response.statusCode}");
    return null;
  }
}
