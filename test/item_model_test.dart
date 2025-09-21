import 'package:find_it/models/item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ItemModel serializes optional fields', () {
    final item = ItemModel(
      name: 'Passport',
      description: 'Government issued ID',
      locationSpecification: 'Top drawer',
      tags: ['travel', 'id'],
      imagePath: '/tmp/passport.png',
    );

    final json = item.toJson();
    expect(json['name'], item.name);
    expect(json['description'], item.description);
    expect(json['locationSpecification'], item.locationSpecification);
    expect(json['tags'], item.tags);
    expect(json['imagePath'], item.imagePath);

    final restored = ItemModel.fromJson(json);
    expect(restored.name, item.name);
    expect(restored.description, item.description);
    expect(restored.locationSpecification, item.locationSpecification);
    expect(restored.tags, item.tags);
    expect(restored.imagePath, item.imagePath);
  });
}
