import 'package:flutter/material.dart';
import 'package:learning_flutter/startup_name_generator_bloc.dart';

import 'db.dart';

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  StartupNameGeneratorBloc businessLogic = StartupNameGeneratorBloc();

  final _biggerFont = const TextStyle(fontSize: 18.0);

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
    return StreamBuilder<Set<StartupName>>(
      stream: businessLogic.storedNames,
      builder: (context, snapshot) {
        var data = snapshot.data;
        if (data != null) {
          return ListView.separated(
            itemCount: data.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              // NOTE: index is from the current item being built and can be
              // used to estimate the scroll position
              businessLogic.scrolledAt(index);
              return _buildRow(data.toList()[index]);
            },
            separatorBuilder: (context, index) => Divider(),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildRow(StartupName name) {
    return ListTile(
      title: Text(name.asPascalCase, style: _biggerFont),
      trailing: Icon(
        name.saved == 1 ? Icons.favorite : Icons.favorite_border,
        color: name.saved == 1 ? Colors.red : null,
      ),
      onTap: () => businessLogic.toggleSaved(name),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          StartupNameGeneratorBloc businessLogic = StartupNameGeneratorBloc();
          return StreamBuilder<Set<StartupName>>(
            stream: businessLogic.savedNames,
            builder: (context, snapshot) {
              var data = snapshot.data;
              if (data == null) {
                data = Set<StartupName>();
              }
              final tiles = data.map((StartupName pair) {
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
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    businessLogic.dispose();
    super.dispose();
  }
}
