import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'db.dart';

Future<List<StartupName>> fetchStartupNames(int numberOfNames) async {
  final int numberOfWords = numberOfNames * 2;
  final response = await http.get(
    Uri.parse(
        'https://random-word-api.herokuapp.com/word?number=$numberOfWords'),
    // Send authorization headers to the backend.
    headers: {
      HttpHeaders.authorizationHeader: 'Basic your_api_token_here',
    },
  );
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<StartupName> names = <StartupName>[];
    List responseBody = jsonDecode(response.body);
    for (int i = 0; i < numberOfWords; i += 2) {
      names.add(StartupName(
          firstWord: responseBody[i],
          secondWord: responseBody[i + 1],
          saved: 0));
    }
    return names;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}
