import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PembukuanPage extends StatefulWidget {
  const PembukuanPage({super.key});

  @override
  State<PembukuanPage> createState() => _PembukuanPageState();
}

class _PembukuanPageState extends State<PembukuanPage> {
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  String _kategori = 'Pemasukkan'; // Default value
  DateTime? _selectedDate;

  Future<void> _submitData() async {
    final String nominal = _nominalController.text;

    // Validate input
    if (nominal.isEmpty || double.tryParse(nominal) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Nominal harus berupa angka dan tidak boleh kosong'),
                backgroundColor: Colors.red,
            ),
        );
        return; // Stop execution if any field is empty or invalid
    }

    final String tanggal = _selectedDate != null ? _selectedDate!.toIso8601String().split('T')[0] : '';
    final String keterangan = _keteranganController.text;

    // Validate input
    if (nominal.isEmpty || tanggal.isEmpty || keterangan.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Data Belum Terisi Semua'),
                backgroundColor: Colors.red,
            ),
        );
        return; // Stop execution if any field is empty
    }

    final response = await http.post(
        Uri.parse('http://localhost/apielectrocare/insert_pembukuan.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
            'kategori': _kategori,
            'nominal': nominal,
            'tanggal': tanggal,
            'keterangan': keterangan,
        },
    );

    if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                content: Text('Data Berhasil Ditambahkan'),
                backgroundColor: Colors.green,
            ),
            );

            // Reset fields after successful submission
            _nominalController.clear();
            _keteranganController.clear();
            setState(() {
                _kategori = 'Pemasukkan'; // Reset category to default
                _selectedDate = null; // Reset date
            });
        } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(responseData['message'])),
            );
        }
    } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit data')),
        );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pembukuan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFF1D1D),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kategori',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: DropdownButton<String>(
                value: _kategori,
                isExpanded: true,
                underline: SizedBox(), // Remove underline
                onChanged: (String? newValue) {
                  setState(() {
                    _kategori = newValue!;
                  });
                },
                items: <String>['Pemasukkan', 'Pengeluaran']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(value),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nominal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nominalController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const Text(
              'Tanggal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                hintText: _selectedDate != null
                    ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                    : 'Pilih Tanggal',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Keterangan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _keteranganController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(15),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF1D1D), // Change to red
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Change text color to white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
