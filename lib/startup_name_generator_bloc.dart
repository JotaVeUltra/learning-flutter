import 'dart:async';

import 'package:learning_flutter/db.dart';
import 'package:learning_flutter/request.dart';

class StartupNameGeneratorBloc {
  Set<StartupName> _storedNames = {};
  StreamController<Set<StartupName>> storedNamesController =
      StreamController<Set<StartupName>>();
  Stream<Set<StartupName>> get storedNames => storedNamesController.stream;

  Set<StartupName> _savedNames = {};
  StreamController<Set<StartupName>> savedNamesController =
      StreamController<Set<StartupName>>();
  Stream<Set<StartupName>> get savedNames => savedNamesController.stream;

  bool _awaitingForResponse = false;

  StartupNameGeneratorBloc() {
    ensureDatabaseHasNames();
  }

  Future<void> ensureDatabaseHasNames() async {
    await retrieveStoredStartupNames();
    if (_storedNames.isEmpty) {
      await fetchNewNames();
    }
  }

  Future<void> fetchNewNames() async {
    if (!_awaitingForResponse) {
      _awaitingForResponse = true;
      List<StartupName> startupNames = await fetchStartupNames(100);
      startupNames.forEach((name) => insertName(name));
      await retrieveStoredStartupNames();
      _awaitingForResponse = false;
    }
  }

  Future<void> retrieveStoredStartupNames() async {
    _storedNames = Set.from(await names());
    _savedNames = _storedNames.where((name) => name.saved == 1).toSet();
    storedNamesController.add(_storedNames);
    savedNamesController.add(_savedNames);
  }

  void scrolledAt(int index) {
    if (index >= _storedNames.length - 50) {
      fetchNewNames();
    }
  }

  Future<void> toggleSaved(StartupName startupName) async {
    await updateSaveStateForStartupName(startupName);
    await retrieveStoredStartupNames();
  }

  void dispose() {
    storedNamesController.close();
    savedNamesController.close();
  }
}
