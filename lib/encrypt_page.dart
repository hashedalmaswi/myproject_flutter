import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'crypto_helper.dart';
import 'history_page.dart';
import 'settings_page.dart';

/// صفحة التشفير: إدخال نص + اختيار خوارزمية + نسخ/مسح/إضافة للسجل
class EncryptPage extends StatefulWidget {
  final AppSettings settings;
  const EncryptPage({super.key, required this.settings});

  @override
  State<EncryptPage> createState() => _EncryptPageState();
}

class _EncryptPageState extends State<EncryptPage> {
  final TextEditingController _input = TextEditingController();
  final TextEditingController _customKey = TextEditingController();
  String _algorithm = 'AES';
  String _output = '';
  bool _useCustomKey = false;

  final _algos = const ['AES', 'Base64', 'Caesar'];

  void _doEncrypt() async {
    FocusScope.of(context).unfocus();
    final text = _input.text;
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رجاءً أدخل نصًا للتشفير')),
      );
      return;
    }

    String key = widget.settings.aesKey;
    if (_algorithm == 'AES' && _useCustomKey) {
      key = _customKey.text.trim().isEmpty ? key : _customKey.text.trim();
    }

    final out = CryptoHelper.encryptUnified(
      algorithm: _algorithm,
      text: text,
      aesKey: key,
      caesarShift: widget.settings.caesarShift,
    );

    setState(() => _output = out);

    await HistoryManager.add(
      HistoryEntry(
        action: 'Encrypt',
        algorithm: _algorithm,
        input: text,
        output: out,
        time: DateTime.now(),
      ),
    );
  }

  void _copyOutput() {
    if (_output.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ النص المشفر')),
    );
  }

  void _clearAll() {
    _input.clear();
    _customKey.clear();
    setState(() => _output = '');
  }

  Widget _buildAlgoSelector() {
    return DropdownButtonFormField<String>(
      value: _algorithm,
      decoration: const InputDecoration(
        labelText: 'اختر الخوارزمية',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.security),
      ),
      items: _algos
          .map((a) => DropdownMenuItem(value: a, child: Text(a)))
          .toList(),
      onChanged: (v) => setState(() => _algorithm = v!),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('النص الأصلي:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _input,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'اكتب النص هنا...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _buildAlgoSelector(),
            if (_algorithm == 'AES') ...[
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('استخدام مفتاح مخصص لهذه العملية'),
                value: _useCustomKey,
                onChanged: (v) => setState(() => _useCustomKey = v),
              ),
              if (_useCustomKey)
                TextField(
                  controller: _customKey,
                  decoration: const InputDecoration(
                    labelText: 'مفتاح AES المخصص',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.vpn_key),
                    helperText: 'سيتم ضبط الطول تلقائيًا إلى 32 حرفًا',
                  ),
                ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _doEncrypt,
                    icon: const Icon(Icons.lock),
                    label: const Text('تشفير'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.clear),
                  label: const Text('مسح'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputCard() {
    return Card(
      color: Colors.teal.shade50,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('النص المشفر:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: SelectableText(_output, style: const TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _copyOutput,
                  icon: const Icon(Icons.copy),
                  label: const Text('نسخ'),
                ),
                const Spacer(),
                Icon(
                  _algorithm == 'AES'
                      ? Icons.shield
                      : _algorithm == 'Base64'
                      ? Icons.compare_arrows
                      : Icons.rotate_90_degrees_ccw,
                  color: Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor.withOpacity(.1), Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(.2)),
      ),
      padding: const EdgeInsets.all(12),
      child: const Text(
        'ملاحظة تعليمية: استخدام IV ثابت ومفاتيح محفوظة محليًا مناسب لأغراض العرض فقط. '
            'في المشاريع الحقيقية يجب إدارة المفاتيح بأمان واستعمال IV عشوائي لكل رسالة.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 التشفير'),
        actions: [
          IconButton(
            tooltip: 'السجل',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            ),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildInputCard(),
            _buildOutputCard(),
            _buildInfoNote(),
          ],
        ),
      ),
    );
  }
}
