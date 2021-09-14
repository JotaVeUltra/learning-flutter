import 'dart:async';

import 'package:learning_flutter/models/StartupName.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> createDatabase() async {
  // Open the database and store the reference.
  return openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'names.db'),
    // When the database is first created, create a table to store names.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE names(id INTEGER PRIMARY KEY, first_word TEXT, second_word TEXT, saved INTEGER)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
}

Future<StartupName> insertName(StartupName name) async {
  // Define a function that inserts names into the database
  // Get a reference to the database.
  final db = await createDatabase();

  // Insert the Name into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same name is inserted twice.
  //
  // In this case, replace any previous data.
  int id = await db.insert(
    'names',
    name.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  return await getName(id);
}

Future<List<StartupName>> names() async {
  // A method that retrieves all the names from the names table.
  // Get a reference to the database.
  final db = await createDatabase();

  // Query the table for all The Names.
  final List<Map<String, dynamic>> maps = await db.query('names');

  // Convert the List<Map<String, dynamic> into a List<Name>.
  return List.generate(maps.length, (i) {
    return StartupName(
      id: maps[i]['id'],
      firstWord: maps[i]['first_word'],
      secondWord: maps[i]['second_word'],
      saved: maps[i]['saved'],
    );
  });
}

Future<StartupName> getName(int id) async {
  // A method that retrieves a name from the names table.
  // Get a reference to the database.
  final db = await createDatabase();

  // Query the table for a specific name.
  final List<Map<String, dynamic>> map = await db.query(
    'names',
    where: 'id = ?',
    whereArgs: [id],
  );

  // Convert the List<Map<String, dynamic>> into a List<Name>.
  return StartupName(
    id: map[0]['id'],
    firstWord: map[0]['first_word'],
    secondWord: map[0]['second_word'],
    saved: map[0]['saved'],
  );
}

Future<void> updateSaveStateForStartupName(StartupName name) async {
  // A method that updates the save state for a name.
  // Get a reference to the database.
  name = StartupName(
    id: name.id,
    firstWord: name.firstWord,
    secondWord: name.secondWord,
    saved: (name.saved - 1).abs(),
  );

  // Update the save state for a specific name.
  await updateName(name);
}

Future<void> updateName(StartupName name) async {
  // Get a reference to the database.
  final db = await createDatabase();

  // Update the given Name.
  await db.update(
    'names',
    name.toMap(),
    // Ensure that the Name has a matching id.
    where: 'id = ?',
    // Pass the Name's id as a whereArg to prevent SQL injection.
    whereArgs: [name.id],
  );
}
