import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'db_test.dart';

Future<List<StartupName>> fetchStartupNames(int numberOfNames) async {
  final int numberOfWords = numberOfNames * 2;
  final response = await http.get(Uri.parse(
      'https://random-word-api.herokuapp.com/word?number=$numberOfWords'));
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

// class Album {
//   final int userId;
//   final int id;
//   final String title;

//   Album({
//     required this.userId,
//     required this.id,
//     required this.title,
//   });

//   factory Album.fromJson(Map<String, dynamic> json) {
//     return Album(
//       userId: json['userId'],
//       id: json['id'],
//       title: json['title'],
//     );
//   }
// }

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<StartupName>> futureNames;

  @override
  void initState() {
    super.initState();
    futureNames = fetchStartupNames(5);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<List<StartupName>>(
            future: futureNames,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data);
                return Text(snapshot.data![0].firstWord +
                    ' ' +
                    snapshot.data![0].secondWord);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
