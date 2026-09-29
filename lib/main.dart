import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vpay_app2/pages/auth/login_page.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
  runApp(const VPay());
}

class VPay extends StatelessWidget {
  const VPay({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V-Pay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
