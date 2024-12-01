import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class ThemeService {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  /// Consulta o estado modo escuro nos arquivos locais e retorna se estiver ativado
  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  /// carrega o modo escuro dos arquivos locais, se estiver falso significa modo claro ativo
  bool _loadThemeFromBox() => _box.read(_key) ?? false;

  /// salva o modo escuro nos arquivos locais
  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  /// muda o tema e salva nos arquivos locais
  void switchTheme() {
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    _saveThemeToBox(!_loadThemeFromBox());
  }
}
