import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  // Create a Name and add it to the names table
  var teaHost = StartupName(
    id: 0,
    firstWord: 'tea',
    secondWord: 'host',
    saved: 0,
  );

  await insertName(teaHost);

  // Now, use the method to retrieve all the names.
  print(await names()); // Prints a list that include TeaHost.

  // Update TeaHost's saved and save it to the database.
  teaHost = StartupName(
    id: teaHost.id,
    firstWord: teaHost.firstWord,
    secondWord: teaHost.secondWord,
    saved: (teaHost.saved - 1).abs(),
  );
  await updateName(teaHost);

  // Print the updated results.
  print(await names()); // Prints TeaHost with saved 1.

  // Delete TeaHost from the database.
  await deleteName(teaHost.id!);

  // Print the list of names (empty).
  print(await names());
}

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

Future<int> insertName(StartupName name) async {
  // Define a function that inserts names into the database
  // Get a reference to the database.
  final db = await createDatabase();

  // Insert the Name into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same name is inserted twice.
  //
  // In this case, replace any previous data.
  return await db.insert(
    'names',
    name.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
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

Future<StartupName> getNameWith(firstWord, secondWord) async {
  // A method that retrieves a name from the names table.
  // Get a reference to the database.
  final db = await createDatabase();

  // Query the table for a specific name.
  final List<Map<String, dynamic>> map = await db.query(
    'names',
    where: 'first_word = ? AND second_word = ?',
    whereArgs: [firstWord, secondWord],
  );

  // Convert the List<Map<String, dynamic>> into a List<Name>.
  return StartupName(
    id: map[0]['id'],
    firstWord: map[0]['first_word'],
    secondWord: map[0]['second_word'],
    saved: map[0]['saved'],
  );
}

Future<void> updateSaveStateForNameWith(firstWord, secondWord) async {
  // A method that updates the save state for a name.
  // Get a reference to the database.
  final db = await createDatabase();

  StartupName name = await getNameWith(firstWord, secondWord);
  name = StartupName(
    id: name.id,
    firstWord: name.firstWord,
    secondWord: name.secondWord,
    saved: (name.saved - 1).abs(),
  );

  // Update the save state for a specific name.
  await db.update(
    'names',
    name.toMap(),
    where: 'first_word = ? AND second_word = ?',
    whereArgs: [firstWord, secondWord],
  );
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

Future<void> deleteName(int id) async {
  // Get a reference to the database.
  final db = await createDatabase();

  // Remove the Name from the database.
  await db.delete(
    'names',
    // Use a `where` clause to delete a specific name.
    where: 'id = ?',
    // Pass the Name's id as a whereArg to prevent SQL injection.
    whereArgs: [id],
  );
}

Future<void> deleteNameByName(String first, String second) async {
  // Get a reference to the database.
  final db = await createDatabase();

  // Remove the Name from the database.
  await db.delete(
    'names',
    // Use a `where` clause to delete a specific name.
    where: 'first_word = ? and second_word = ?',
    // Pass the Name's name as a whereArg to prevent SQL injection.
    whereArgs: [first, second],
  );
}

class StartupName {
  final int? id;
  final String firstWord;
  final String secondWord;
  final int saved;

  StartupName({
    this.id,
    required this.firstWord,
    required this.secondWord,
    required this.saved,
  });

  factory StartupName.fromJson(List<dynamic> json) {
    return StartupName(firstWord: json[0], secondWord: json[1], saved: 0);
  }

  // Convert a Name into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_word': firstWord,
      'second_word': secondWord,
      'saved': saved,
    };
  }

  // Implement toString to make it easier to see information about
  // each name when using the print statement.
  @override
  String toString() {
    return 'Name{id: $id, first word: $firstWord, second word: $secondWord}, saved: $saved}';
  }
}
