import 'package:flutter/material.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool isTwoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Security',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0E5CA8), Color(0xFF103A70)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Keamanan Akun',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: const Icon(Icons.lock_reset),
            title: const Text('Ubah Password'),
            subtitle: const Text('Ganti kata sandi akun Anda'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text("Fitur Belum Tersedia"),
                      content: const Text(
                        "Halaman ubah password sedang dikembangkan.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Tutup"),
                        ),
                      ],
                    ),
              );
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: const Icon(Icons.phonelink_lock),
            title: const Text('Verifikasi Dua Langkah'),
            subtitle: const Text('Tambahan keamanan untuk login'),
            trailing: Switch(
              value: isTwoFactorEnabled,
              onChanged: (value) {
                setState(() {
                  isTwoFactorEnabled = value;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          const Divider(thickness: 1),
          const SizedBox(height: 16),
          const Text(
            'Tips Keamanan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Jangan pernah membagikan password Anda.\n'
            '• Gunakan password yang kuat dan unik.\n'
            '• Aktifkan verifikasi dua langkah.\n'
            '• Waspada terhadap penipuan dan phishing.',
            style: TextStyle(height: 1.6),
          ),
        ],
      ),
    );
  }
}
