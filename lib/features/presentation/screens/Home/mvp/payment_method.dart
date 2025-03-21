import 'package:flutter/material.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  // Daftar metode pembayaran
  final List<Map<String, dynamic>> eWallets = [
    {"name": "OVO", "icon": Image.asset("assets/icons/ovo.png")},
    {"name": "GoPay", "icon": Image.asset("assets/icons/GOPAY.png")},
  ];

  final List<Map<String, dynamic>> bankTransfers = [
    {"name": "BCA", "icon": Image.asset("assets/icons/BCA.png")},
    {"name": "BNI", "icon": Image.asset("assets/icons/BNI.png")},
    {"name": "Mandiri", "icon": Image.asset("assets/icons/MANDIRI.png")},
  ];

  String? _selectedMethod; // Menyimpan metode yang dipilih

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Metode Pembayaran")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian E-Wallet
            Text(
              "E-Wallet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...eWallets.map((method) => _buildPaymentOption(method)),
    
            SizedBox(height: 20),
    
            // Bagian Transfer Bank
            Text(
              "Transfer Bank",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...bankTransfers.map((method) => _buildPaymentOption(method)),
    
            Spacer(),
    
            // Tombol Konfirmasi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedMethod != null) {
                    Navigator.pop(context, _selectedMethod);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Pilih metode pembayaran terlebih dahulu!"),
                      ),
                    );
                  }
                },
                child: Text("Konfirmasi"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(Map<String, dynamic> method) {
    return ListTile(
      leading: method["icon"],
      title: Text(method["name"]),
      trailing: Radio(
        value: method["name"],
        groupValue: _selectedMethod,
        onChanged: (value) {
          setState(() {
            _selectedMethod = value.toString();
          });
        },
      ),
      onTap: () {
        setState(() {
          _selectedMethod = method["name"];
        });
      },
    );
  }
}
