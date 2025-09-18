import 'package:flutter/material.dart';
import 'encrypt_page.dart';
import 'decrypt_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'about_page.dart';

/// الصفحة الرئيسية: بطاقات كبيرة + Drawer + Bottom Area
class HomePage extends StatelessWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;
  const HomePage({super.key, required this.settings, required this.onSettingsChanged});

  Widget _bigCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(.08), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(.1),
                radius: 28,
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text('القائمة الرئيسية',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('تشفير'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EncryptPage(settings: settings)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_open),
            title: const Text('فك التشفير'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DecryptPage(settings: settings)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('السجل'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(
                    settings: settings,
                    onChanged: onSettingsChanged,
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('حول التطبيق'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _bottomInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: Text(
        'المفتاح الحالي (AES): ${settings.aesKey.isEmpty ? 'افتراضي' : 'مخصص'} • '
            'إزاحة Caesar: ${settings.caesarShift} • الثيم: ${settings.mode == ThemeMode.dark ? 'داكن' : 'فاتح'}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SecureApp'),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _bigCard(
            icon: Icons.lock,
            title: 'تشفير النصوص',
            subtitle: 'AES / Base64 / Caesar مع خيارات متقدمة',
            color: Colors.teal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EncryptPage(settings: settings)),
            ),
          ),
          _bigCard(
            icon: Icons.lock_open,
            title: 'فك التشفير',
            subtitle: 'أعد النص الأصلي مع التحقق من المدخلات',
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DecryptPage(settings: settings)),
            ),
          ),
          _bigCard(
            icon: Icons.history,
            title: 'سجل العمليات',
            subtitle: 'استعرض وفلتر وانسخ أو احذف السجل',
            color: Colors.indigo,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            ),
          ),
          _bigCard(
            icon: Icons.settings,
            title: 'الإعدادات',
            subtitle: 'اللون/الوضع والمفتاح وإزاحة Caesar',
            color: p,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SettingsPage(settings: settings, onChanged: onSettingsChanged),
              ),
            ),
          ),
          _bigCard(
            icon: Icons.info,
            title: 'حول التطبيق',
            subtitle: 'معلومات وأهداف تعليمية',
            color: Colors.brown,
            onTap: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
          ),
          const SizedBox(height: 8),
          _bottomInfo(context),
        ],
      ),
    );
  }
}
