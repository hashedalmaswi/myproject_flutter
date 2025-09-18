import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HistoryEntry: نموذج لعنصر سجل
class HistoryEntry {
  final String action; // Encrypt | Decrypt
  final String algorithm; // AES | Base64 | Caesar
  final String input;
  final String output;
  final DateTime time;

  HistoryEntry({
    required this.action,
    required this.algorithm,
    required this.input,
    required this.output,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'action': action,
    'algorithm': algorithm,
    'input': input,
    'output': output,
    'time': time.toIso8601String(),
  };

  static HistoryEntry fromJson(Map<String, dynamic> j) => HistoryEntry(
    action: j['action'],
    algorithm: j['algorithm'],
    input: j['input'],
    output: j['output'],
    time: DateTime.parse(j['time']),
  );
}

/// HistoryManager: تخزين/قراءة السجل عبر SharedPreferences
class HistoryManager {
  static const _key = 'secureapp_history';

  static Future<void> add(HistoryEntry e) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_key) ?? [];
    list.insert(0, jsonEncode(e.toJson()));
    await sp.setStringList(_key, list.take(200).toList()); // سقف 200 عنصر
  }

  static Future<List<HistoryEntry>> load() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_key) ?? [];
    return list
        .map((s) => HistoryEntry.fromJson(jsonDecode(s)))
        .toList(growable: false);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }
}

/// صفحة السجل: فلترة + بحث + نسخ + حذف
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryEntry> _all = [];
  List<HistoryEntry> _view = [];
  String _query = '';
  String _algoFilter = 'All';
  String _actionFilter = 'All';

  final _algos = ['All', 'AES', 'Base64', 'Caesar'];
  final _actions = ['All', 'Encrypt', 'Decrypt'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await HistoryManager.load();
    setState(() {
      _all = data;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _view = _all.where((e) {
      final okQuery = _query.isEmpty ||
          e.input.toLowerCase().contains(_query) ||
          e.output.toLowerCase().contains(_query);
      final okAlgo = _algoFilter == 'All' || e.algorithm == _algoFilter;
      final okAction = _actionFilter == 'All' || e.action == _actionFilter;
      return okQuery && okAlgo && okAction;
    }).toList();
  }

  Future<void> _clearAll() async {
    await HistoryManager.clear();
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف السجل بالكامل')),
      );
    }
  }

  Widget _buildFilters() {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'بحث في المدخلات/المخرجات',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (v) {
            setState(() {
              _query = v.toLowerCase();
              _applyFilters();
            });
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _algoFilter,
                decoration: const InputDecoration(
                  labelText: 'الخوارزمية',
                  border: OutlineInputBorder(),
                ),
                items: _algos
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _algoFilter = v!;
                    _applyFilters();
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _actionFilter,
                decoration: const InputDecoration(
                  labelText: 'العملية',
                  border: OutlineInputBorder(),
                ),
                items: _actions
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _actionFilter = v!;
                    _applyFilters();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItem(HistoryEntry e) {
    final color = e.action == 'Encrypt' ? Colors.teal : Colors.orange;
    final icon = e.action == 'Encrypt' ? Icons.lock : Icons.lock_open;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(.15),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 10),
                Text(
                  '${e.action} • ${e.algorithm}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.shade700,
                  ),
                ),
                const Spacer(),
                Text(
                  _fmt(e.time),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('المدخل:', style: TextStyle(color: Colors.grey.shade700)),
            SelectableText(
              e.input,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text('الناتج:', style: TextStyle(color: Colors.grey.shade700)),
            SelectableText(
              e.output,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: e.output));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ الناتج')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('نسخ الناتج'),
                ),
                const Spacer(),
                Icon(
                  e.algorithm == 'AES'
                      ? Icons.shield
                      : e.algorithm == 'Base64'
                      ? Icons.compare_arrows
                      : Icons.rotate_90_degrees_ccw,
                  color: color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime t) {
    return '${t.year}/${t.month.toString().padLeft(2, '0')}/${t.day.toString().padLeft(2, '0')} '
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🕘 سجل العمليات'),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'حذف الكل',
            onPressed: _clearAll,
            icon: const Icon(Icons.delete_forever),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _all.isEmpty
            ? const Center(
          child: Text(
            'لا يوجد سجل بعد.\nقم بإجراء عملية تشفير/فك تشفير وسيظهر هنا.',
            textAlign: TextAlign.center,
          ),
        )
            : Column(
          children: [
            _buildFilters(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _view.length,
                itemBuilder: (_, i) => _buildItem(_view[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

