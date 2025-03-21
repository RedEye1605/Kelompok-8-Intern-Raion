import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PilihTanggal extends StatefulWidget {
  final String hintTanggal;
  final TextEditingController controller;

  PilihTanggal({super.key, required this.hintTanggal, required this.controller});

  @override
  State<PilihTanggal> createState() => _PilihTanggalState();
}

class _PilihTanggalState extends State<PilihTanggal> {
  void _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        widget.controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDate(context), 
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        width: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.controller.text.isNotEmpty
                  ? widget.controller.text
                  : widget.hintTanggal,
              style: TextStyle(fontSize: 16),
            ),
            Image.asset('assets/icons/down.png')
          ],
        ),
      ),
    );
  }
}
