import 'package:flutter/material.dart';
import 'home_page.dart';
import 'settings_page.dart';

/// نقطة التشغيل: نحمل الإعدادات أولًا ثم نبني التطبيق.
/// نخزّن الحالة في State لعكس تغييرات الإعدادات مباشرة.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _Bootstrap());
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  AppSettings? _settings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await SettingsStore.load();
    setState(() => _settings = s);
  }

  void _updateSettings(AppSettings s) {
    setState(() => _settings = s);
  }

  ThemeData _themeFrom(AppSettings s) {
    final base = s.mode == ThemeMode.dark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      colorScheme: (s.mode == ThemeMode.dark
          ? const ColorScheme.dark()
          : const ColorScheme.light())
          .copyWith(primary: s.seed, secondary: s.seed.shade400),
      primaryColor: s.seed,
      appBarTheme: AppBarTheme(backgroundColor: s.seed),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: s.mode == ThemeMode.dark
            ? Colors.white.withOpacity(.06)
            : s.seed.shade50,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: s.seed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final theme = _themeFrom(_settings!);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SecureApp',
      theme: theme,
      darkTheme: theme,
      themeMode: _settings!.mode,
      home: HomePage(
        settings: _settings!,
        onSettingsChanged: _updateSettings,
      ),
    );
  }
}