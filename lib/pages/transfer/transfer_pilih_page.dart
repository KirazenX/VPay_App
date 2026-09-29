import 'package:flutter/material.dart';
import 'package:vpay_app2/pages/transfer/transfer_nominal_page.dart';

class TransferPilihPage extends StatefulWidget {
  const TransferPilihPage({super.key});

  @override
  State<TransferPilihPage> createState() => _TransferPilihPageState();
}

class _TransferPilihPageState extends State<TransferPilihPage> {
  int? selectedIndex;

  final List<Map<String, String>> accounts = [
    {
      'name': 'Shoutaro',
      'accountNumber': '1111 2222 3333 4444',
      'avatar': '👦',
    },
    {'name': 'Arnold', 'accountNumber': '5555 6666 7777 8888', 'avatar': '🧔'},
    {'name': 'Lena', 'accountNumber': '9999 0000 1111 2222', 'avatar': '👧'},
    {
      'name': 'Goddokira',
      'accountNumber': '1234 5678 9101 1121',
      'avatar': '🧙‍♂️',
    },
    {
      'name': 'Abigail',
      'accountNumber': '3333 4444 5555 6666',
      'avatar': '👩‍🎤',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF338AE7),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        title: const Text(
          "Transfer ke",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0E5CA8), Color(0xFF103A70)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Ketik username atau rekening',
                  suffixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: List.generate(accounts.length, (index) {
                    final account = accounts[index];
                    final isSelected = selectedIndex == index;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xFFD6F3FF)
                                  : const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              account['avatar']!,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                account['name']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check, color: Colors.green),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 30),
              const _TransferTabSection(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      selectedIndex != null
                          ? () {
                            final selected = accounts[selectedIndex!];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => TransferNominalPage(
                                      name: selected['name']!,
                                      accountNumber: selected['accountNumber']!,
                                    ),
                              ),
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.black54,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Selanjutnya",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransferTabSection extends StatefulWidget {
  const _TransferTabSection();

  @override
  State<_TransferTabSection> createState() => _TransferTabSectionState();
}

class _TransferTabSectionState extends State<_TransferTabSection> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [_buildTab('Favorit', 0), _buildTab('Terbaru', 1)],
            ),
          ),
          const SizedBox(height: 30),
          const Icon(Icons.search_off, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            selectedTab == 0
                ? "Kamu belum memiliki akun favorit"
                : "Belum ada riwayat transfer terbaru",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Expanded _buildTab(String title, int index) {
    final bool isActive = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
