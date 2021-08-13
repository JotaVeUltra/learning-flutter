// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'db.dart';
import 'request.dart';

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <StartupName>[];
  final _saved = <StartupName>{};
  final _biggerFont = const TextStyle(fontSize: 18.0);
  bool waitingForResponse = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: buildSuggestions(),
    );
  }

  Widget buildSuggestions() {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done ||
            _suggestions.length > 0) {
          return _buildSuggestions();
        } else {
          return Container();
        }
      },
      future: retrieveStoredStartupNames(),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        itemCount: _suggestions.length * 2,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return const Divider();

          final index = i ~/ 2;

          if (index >= _suggestions.length - 50 || _suggestions.length == 0) {
            addAllGeneratedStartupNames();
          }
          return _buildRow(_suggestions[index]);
        });
  }

  void processStartupName(StartupName startupName) {
    _suggestions.add(startupName);
    if (startupName.saved == 1) {
      _saved.add(startupName);
    }
  }

  Future<void> retrieveStoredStartupNames() async {
    List<StartupName> startupNames = await names();

    if (_suggestions.length == 0) {
      startupNames.forEach((name) => {processStartupName(name)});
    }
    if (_suggestions.length == 0) {
      addAllGeneratedStartupNames();
    }
  }

  void addAllGeneratedStartupNames() async {
    if (!waitingForResponse) {
      waitingForResponse = true;
      List<StartupName> startupNames = await fetchStartupNames(100);
      setState(() {
        startupNames.forEach((name) =>
            insertName(name).then((name) => processStartupName(name)));
      });
      waitingForResponse = false;
    }
  }

  Widget _buildRow(StartupName name) {
    final alreadySaved = _saved.contains(name);

    return ListTile(
      title: Text(name.asPascalCase, style: _biggerFont),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          updateSaveStateForStartupName(name);
          if (alreadySaved) {
            _saved.remove(name);
          } else {
            _saved.add(name);
          }
        });
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final tiles = _saved.map((StartupName pair) {
            return ListTile(
              title: Text(pair.asPascalCase, style: _biggerFont),
            );
          });
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}
