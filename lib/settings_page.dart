import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppSettings: تخزين الإعدادات (لون، وضع ليلي، مفتاح AES، إزاحة Caesar)
class AppSettings {
  ThemeMode mode;
  MaterialColor seed;
  String aesKey;
  int caesarShift;

  AppSettings({
    required this.mode,
    required this.seed,
    required this.aesKey,
    required this.caesarShift,
  });

  AppSettings copyWith({
    ThemeMode? mode,
    MaterialColor? seed,
    String? aesKey,
    int? caesarShift,
  }) {
    return AppSettings(
      mode: mode ?? this.mode,
      seed: seed ?? this.seed,
      aesKey: aesKey ?? this.aesKey,
      caesarShift: caesarShift ?? this.caesarShift,
    );
  }
}

/// SettingsStore: يحفظ/يسترجع الإعدادات محليًا
class SettingsStore {
  static const _kMode = 'mode';
  static const _kSeed = 'seed';
  static const _kKey = 'aes_key';
  static const _kShift = 'caesar_shift';

  static Future<void> save(AppSettings s) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kMode, s.mode.name);
    await sp.setInt(_kSeed, _materialToIndex(s.seed));
    await sp.setString(_kKey, s.aesKey);
    await sp.setInt(_kShift, s.caesarShift);
  }

  static Future<AppSettings> load() async {
    final sp = await SharedPreferences.getInstance();
    final modeStr = sp.getString(_kMode) ?? ThemeMode.light.name;
    final seedIdx = sp.getInt(_kSeed) ?? 5;
    final key = sp.getString(_kKey) ?? 'my_secure_default_key_for_demo_only';
    final shift = sp.getInt(_kShift) ?? 3;

    return AppSettings(
      mode: ThemeMode.values.firstWhere((m) => m.name == modeStr,
          orElse: () => ThemeMode.light),
      seed: _indexToMaterial(seedIdx),
      aesKey: key,
      caesarShift: shift,
    );
  }

  static int _materialToIndex(MaterialColor c) {
    final all = _palette();
    return all.indexWhere((e) => e.value == c.value).clamp(0, all.length - 1);
  }

  static MaterialColor _indexToMaterial(int i) {
    final all = _palette();
    if (i < 0 || i >= all.length) return Colors.indigo;
    return all[i];
  }

  static List<MaterialColor> _palette() => const [
    Colors.indigo,
    Colors.deepPurple,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.pink,
    Colors.red,
    Colors.brown,
    Colors.cyan,
  ];
}

/// صفحة الإعدادات: تغيير الثيم/اللون/المفتاح/الإزاحة
class SettingsPage extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onChanged;
  const SettingsPage({super.key, required this.settings, required this.onChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AppSettings _local;

  @override
  void initState() {
    super.initState();
    _local = widget.settings;
  }

  void _saveAndNotify() async {
    await SettingsStore.save(_local);
    widget.onChanged(_local);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الإعدادات')),
      );
    }
  }

  Widget _buildThemeToggle() {
    return SwitchListTile(
      title: const Text('الوضع الداكن'),
      subtitle: const Text('تبديل بين الفاتح والداكن'),
      value: _local.mode == ThemeMode.dark,
      onChanged: (v) {
        setState(() {
          _local = _local.copyWith(mode: v ? ThemeMode.dark : ThemeMode.light);
        });
      },
    );
  }

  Widget _buildColorPicker() {
    final colors = SettingsStore._palette();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('لون الواجهة (Primary Color):',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in colors)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _local = _local.copyWith(seed: c);
                  });
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _local.seed.value == c.value
                          ? Colors.black
                          : Colors.white,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 4,
                        offset: Offset(0, 2),
                        color: Colors.black12,
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyField() {
    final controller = TextEditingController(text: _local.aesKey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('مفتاح AES (سيتم ضبطه إلى 32 حرفًا تلقائيًا):',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'أدخل مفتاح مخصص (اختياري)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.vpn_key),
          ),
          onChanged: (v) => _local = _local.copyWith(aesKey: v),
        ),
      ],
    );
  }

  Widget _buildShiftSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('إزاحة Caesar:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: _local.caesarShift.toDouble(),
          min: 1,
          max: 25,
          divisions: 24,
          label: '${_local.caesarShift}',
          onChanged: (v) {
            setState(() {
              _local = _local.copyWith(caesarShift: v.toInt());
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙ الإعدادات'),
        actions: [
          IconButton(
            onPressed: _saveAndNotify,
            tooltip: 'حفظ',
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildThemeToggle(),
            const SizedBox(height: 12),
            _buildColorPicker(),
            const SizedBox(height: 16),
            _buildKeyField(),
            const SizedBox(height: 16),
            _buildShiftSlider(),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _saveAndNotify,
              icon: const Icon(Icons.check),
              label: const Text('حفظ التغييرات'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
