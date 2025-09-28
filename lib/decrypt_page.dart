import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'crypto_helper.dart';
import 'history_page.dart';
import 'settings_page.dart';

/// صفحة فك التشفير: إدخال نص مشفر + اختيار الخوارزمية + نسخ/مسح/سجل
class DecryptPage extends StatefulWidget {
  final AppSettings settings;
  const DecryptPage({super.key, required this.settings});

  @override
  State<DecryptPage> createState() => _DecryptPageState();
}

class _DecryptPageState extends State<DecryptPage> {
  final TextEditingController _input = TextEditingController();
  final TextEditingController _customKey = TextEditingController();
  String _algorithm = 'AES';
  String _output = '';
  bool _useCustomKey = false;


  final _algos = const ['AES', 'Base64', 'Caesar'];

  void _doDecrypt() async {
    FocusScope.of(context).unfocus();
    final text = _input.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مشف')),
      );
      return;
    }

    String key = widget.settings.aesKey;
    if (_algorithm == 'AES' && _useCustomKey) {
      key = _customKey.text.trim().isEmpty ? key : _customKey.text.trim();
    }

    final out = CryptoHelper.decryptUnified(
      algorithm: _algorithm,
      text: text,
      aesKey: key,
      caesarShift: widget.settings.caesarShift,
    );

    setState(() => _output = out);

    await HistoryManager.add(
      HistoryEntry(
        action: 'Decrypt',
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
      const SnackBar(content: Text(' مفكوك')),
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
        labelText:"',
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
              child: Text('النص المشفر:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _input,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'الالنص المشفر هنا...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _buildAlgoSelector(),
            if (_algorithm == 'AES') ...[
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('اتاهذه العملية'),
                value: _useCustomKey,
                onChanged: (v) => setState(() => _useCustomKey = v),
              ),
              if (_useCustomKey)
                TextField(
                  controller: _customKey,
                  decoration: const InputDecoration(
                    labelTexالصص',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Iconvpn_key),
                    helperText: ' 
            
                ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _doDecrypt,
                    icon: const Icon(Icons.lock_open),
                    label: const Text('فك التشفير'),
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
      color: Colors.orange.shade50,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('الناتج:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange.shade200),
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
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100.withOpacity(.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'تلميح: لو ظهرت رسالة خطأ بفك تشفير AES، تأكد أن المفتاح نفسه الذي تم به التشفير '
            'وأن النص فعلاً Base64 صالح.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔓 فك التشفير'),
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
            _buildTip(),
          ],
        ),
      ),
    );
  }
}