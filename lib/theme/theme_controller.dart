// lib/theme/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeController extends ChangeNotifier {
  final SharedPreferences _prefs;

  ThemeController(this._prefs, {String? initialPackId}) {
    _load();
    if (initialPackId != null) {
      _packId = initialPackId;
    }
  }

  /* ----------------- State ----------------- */

  AppThemeMode _mode = AppThemeMode.system;
  Color _seed = const Color(0xFF4F77FE); // default brand
  String _packId = 'default'; // wallpaper/lottie theme pack
  bool _motionEnabled = true;

  /* ----------------- Getters ----------------- */

  AppThemeMode get mode => _mode;
  Color get seed => _seed;
  String get packId => _packId;
  bool get motionEnabled => _motionEnabled;

  ThemeMode get materialMode => switch (_mode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  Brightness platformBrightness(BuildContext context) =>
      MediaQuery.of(context).platformBrightness;

  /* ----------------- Setters ----------------- */

  void setMode(AppThemeMode m) {
    _mode = m;
    _prefs.setInt('theme_mode', m.index);
    notifyListeners();
  }

  void setSeed(Color c) {
    _seed = c;
    _prefs.setInt('theme_seed', c.value);
    notifyListeners();
  }

  Future<void> setPackId(String id) async {
    _packId = id;
    await _prefs.setString('theme_pack', id);
    notifyListeners();
  }

  void setMotionEnabled(bool v) {
    _motionEnabled = v;
    _prefs.setBool('motion_enabled', v);
    notifyListeners();
  }

  /* ----------------- Load from storage ----------------- */

  void _load() {
    final mi = _prefs.getInt('theme_mode');
    if (mi != null && mi >= 0 && mi < AppThemeMode.values.length) {
      _mode = AppThemeMode.values[mi];
    }

    final sv = _prefs.getInt('theme_seed');
    if (sv != null) _seed = Color(sv);

    _packId = _prefs.getString('theme_pack') ?? 'default';
    _motionEnabled = _prefs.getBool('motion_enabled') ?? true;
  }
}
