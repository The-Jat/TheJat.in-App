import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});

class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(16.00) {
    _loadFontSize();
  }

  void _loadFontSize() async {
    var box = await Hive.openBox('settingsBox');
    double savedFontSize = box.get('fontSize', defaultValue: 16.0);
    state = savedFontSize;
  }

  void _saveFontSize(double fontSize) async {
    var box = await Hive.openBox('settingsBox');
    await box.put('fontSize', fontSize);
  }

  void increaseSize() {
    if (state >= 9 && state < 45) {
      final result = state + 1;
      state = result;
      _saveFontSize(result);
    }
  }

  void decreaseSize() {
    if (state > 9 && state <= 45) {
      final result = state - 1;
      state = result;
      _saveFontSize(result);
    }
  }

  void setFontSize(double newSize) {
    state = newSize;
    _saveFontSize(newSize);
  }
}
