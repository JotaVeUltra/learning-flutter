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

  String get asPascalCase {
    return firstWord.substring(0, 1).toUpperCase() +
        firstWord.substring(1) +
        secondWord.substring(0, 1).toUpperCase() +
        secondWord.substring(1);
  }
}
