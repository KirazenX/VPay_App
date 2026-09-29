import 'package:flutter/material.dart';

import '../widgets/vpay_profile_page.dart';

class AboutVPayPage extends StatelessWidget {
  const AboutVPayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VPayPage(
      title: 'About V-Pay',
      icon: Icons.info_outline,
      content: '''
V-Pay adalah dompet digital buatan anak bangsa yang memudahkan transaksi Anda sehari-hari.

Versi Aplikasi: 1.0.0  
Dibuat oleh: Azriel & Tim V-Pay  
Website: www.vpay.id  
Email: support@vpay.id

Kami berkomitmen menghadirkan solusi finansial yang cepat, aman, dan terpercaya.
''',
    );
  }
}
