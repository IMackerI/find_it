import '../models/space_model.dart';

import 'local_database.dart';

class SpacesRepository implements SpaceStorage {
  SpacesRepository({LocalDatabase? database})
      : _database = database ?? LocalDatabase();

  final LocalDatabase _database;

  @override
  Future<void> saveSpaces(List<SpaceModel> spaces) {
    return _database.replaceAllSpaces(spaces);
  }

  @override
  Future<List<SpaceModel>> loadSpaces() {
    return _database.loadSpaces();
  }
}
