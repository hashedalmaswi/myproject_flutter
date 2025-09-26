import 'package:flutter/material.dart';

/// صفة "حول التطبيق": معلومات، نسخة، ملاحظات أمنية، وشكر
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Widget _tile(IconData i, String title, String body, {Color? color}) {
    return Card(
      child: ListTile(
        leading: Icon(i, color: color ?? Colors.indigo),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(body),
      ),
    );
  }

  Widget _badge(String text, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(.1),
        border: Border.all(color: c.withOpacity(.4)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(text, style: TextStyle(color: c, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      
      appBar: AppBar(title: const Text('ℹ حول التطبيق')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary.withOpacity(.15), Colors.white],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withOpacity(.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SecureApp', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text(
                  'تطبيق تعليمي متقدم يوضح طرق التشفير المختلفة (AES، Base64، Caesar) '
                      'مع واجهة أنيقة وسجل عمليات وإعدادات تخصيص.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _badge('Flutter', Colors.blue),
                    _badge('Dart', Colors.teal),
                    _badge('Encrypt', Colors.indigo),
                    _badge('SharedPrefs', Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _tile(Icons.shield, 'تنبيه أمني',
              'هذا التطبيق لأغراض تعليمية. في الإنتاج يجب إدارة المفاتيح على الخادم، واستخدام IV عشوائي لكل رسالة، وتطبيق سياسات أمنية مشددة.',
              color: Colors.red),
          _tile(Icons.code, 'الإصدار', 'v1.0.0 (Academic Demo)'),
          _tile(Icons.person, 'المطوران', ' عبدالقادر:حاشد – مشروع مادة تطبيقات الهاتف'),
          _tile(Icons.email, 'تواصل', 'abood@university.edu'),
        ],
      ),
    );
  }
}
