import 'package:flutter/material.dart';

import '../widgets/vpay_profile_page.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VPayPage(
      title: 'Help Center',
      icon: Icons.help_outline,
      content: '''
Selamat datang di Pusat Bantuan V-Pay!

Topik Populer:
• Cara isi saldo & transfer
• Mengatur ulang kata sandi
• Menambahkan akun favorit
• Riwayat transaksi

Jika pertanyaan Anda tidak terjawab, hubungi kami melalui support@vpay.id
''',
    );
  }
}
