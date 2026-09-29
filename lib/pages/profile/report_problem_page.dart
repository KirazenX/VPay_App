import 'package:flutter/material.dart';

import '../widgets/vpay_profile_page.dart';

class ReportProblemPage extends StatelessWidget {
  const ReportProblemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VPayPage(
      title: 'Report Problem',
      icon: Icons.report_problem_outlined,
      content: '''
Jika Anda mengalami kendala saat menggunakan V-Pay, silakan laporkan dengan detail sebagai berikut:

• Jenis masalah
• Waktu kejadian
• Tangkapan layar (jika ada)
• ID akun Anda

Tim kami siap membantu Anda 24/7.
''',
    );
  }
}
