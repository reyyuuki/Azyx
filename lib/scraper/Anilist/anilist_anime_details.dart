import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

const String GRAPHQL_ENDPOINT = 'https://graphql.anilist.co';

Future<Map<String, dynamic>> fetchAnilistAnimeDetails(String animeId) async {
  const String query = '''
    query (\$id: Int) {
      Media(id: \$id) {
        id
        title {
          romaji
          english
          native
        }
        description
        coverImage {
          large   # Cover image (usually larger)
          medium  # Poster image (smaller version)
        }
        averageScore
        episodes
        type
        season
        seasonYear
        duration
        status
        format
        startDate {
          year
          month
          day
        }
        endDate {
          year
          month
          day
        }
        genres
        studios {
          nodes {
            name
          }
        }
        characters {
          edges {
            node {
              name {
                full
              }
              image {
                large
              }
            }
            voiceActors(language: JAPANESE) {
              name {
                full
              }
              image {
                large
              }
            }
          }
        }
        relations {
          edges {
            node {
              id
              title {
                romaji
                english
              }
              coverImage {
                large
              }
              type
            }
          }
        }
        recommendations {
          edges {
            node {
              mediaRecommendation {
                id
                title {
                  romaji
                  english
                }
                coverImage {
                  large
                }
                type
              }
            }
          }
        }
        nextAiringEpisode {
          airingAt
          timeUntilAiring
        }
        rankings {
          rank
          type
          year
        }
      }
    }
  ''';

  try {
    final response = await http.post(
      Uri.parse(GRAPHQL_ENDPOINT),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "query": query,
        "variables": {"id": int.parse(animeId)},
      }),
    );

    log('Request to AniList: id=$animeId, statusCode=${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final media = data['data']['Media'];

      // Format aired dates (startDate to endDate)
      final startDate = media['startDate'];
      final endDate = media['endDate'];
      String aired = '';
      if (startDate != null) {
        aired = '${startDate['year']}-${startDate['month']?.toString().padLeft(2, '0')}-${startDate['day']?.toString().padLeft(2, '0')}';
        if (endDate != null && endDate['year'] != null) {
          aired += ' to ${endDate['year']}-${endDate['month']?.toString().padLeft(2, '0')}-${endDate['day']?.toString().padLeft(2, '0')}';
        }
      }

      // Mapping title fields and other data
      final updatedMedia = {
        'id': media['id'],
        'name': media['title']['romaji'], // Changed to 'name'
        'english': media['title']['english'],
        'japanese': media['title']['native'], // Changed to 'japanese'
        'description': media['description'],
        'poster': media['coverImage']['medium'],  // Poster image (medium size)
        'coverImage': media['coverImage']['large'], // Cover image (large size)
        'averageScore': media['averageScore'],
        'episodes': media['episodes'].toString(),
        'type': media['type'],
        'season': media['season'],
        'premiered': '${media['season']} ${media['seasonYear']}'.toString(), // Premiered (Season + Year)
        'duration': '${media['duration']}m', // Duration in minutes per episode
        'status': media['status'], // Status of the anime (e.g., FINISHED, RELEASING)
        'rating': (media['averageScore'] / 10) ?? "??", // Rating based on AniList's average score
        'quality': media['format'], // Assuming "format" as the quality field
        'aired': aired.toString(), // Formatted aired dates
        'studios': media['studios']['nodes'],
        'genres': media['genres'],
        'characters': media['characters'],
        'relations': media['relations'],
        'recommendations': media['recommendations'],
      };

      return updatedMedia;
    } else {
      log('Error response: ${response.body}');
      throw Exception('Failed to load anime details: ${response.body}');
    }
  } catch (error) {
    log('Exception: $error');
    throw Exception('Failed to load anime details: $error');
  }
}
