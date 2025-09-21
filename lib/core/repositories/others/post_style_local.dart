import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final postStyleProvider = Provider<PostStyleRepository>((ref) {
  return PostStyleRepository();
});

enum PostDetailStyle {
  classic, // Current style
  magazine, // Magazine-style layout
  minimal, // Clean minimal style
  card, // Card-based layout
  story, // Story-telling focused
}

class PostStyleRepository {
  final _boxKey = 'postStyle';
  final _dataKey = 'selectedPostStyle';

  Future<PostStyleRepository> init() async {
    await Hive.openBox(_boxKey);
    return this;
  }

  bool isUserHasNoStyle() {
    var box = Hive.box(_boxKey);
    return box.get(_dataKey) == null;
  }

  PostDetailStyle getSelectedStyle() {
    var box = Hive.box(_boxKey);
    final styleIndex = box.get(_dataKey) ?? 0;
    return PostDetailStyle.values[styleIndex];
  }

  Future<void> saveSelectedStyle(PostDetailStyle style) async {
    var box = Hive.box(_boxKey);
    await box.put(_dataKey, style.index);
  }
}
