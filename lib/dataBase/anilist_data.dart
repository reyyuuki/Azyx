
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void fetchToken() async {
  final url = Uri.parse("https://anilist.co/api/v2/oauth/token");

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    },
    body: jsonEncode({
      "grant_type": "authorization_code",
      "client_id": "21626", // Replace with your actual client ID
      "client_secret": "Xt98yhUGRnBzzfyd1OeACVS1MzQag3PdxbGwAhdy", // Replace with your actual client secret
      "redirect_uri": "azyx://callback", // Redirect URI
      "code": "{code}" // Replace with the actual authorization code you received
    }),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    print('Access Token: ${responseData['access_token']}');
  } else {
    print('Error: ${response.statusCode}');
  }
}

