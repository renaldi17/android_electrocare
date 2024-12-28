import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({Key? key}) : super(key: key);

  @override
  _LaporanScreenState createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  String? selectedKategori;
  String? selectedTanggal;
  List<dynamic> results = [];
  final TextEditingController tanggalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData(null, null);
  }

  @override
  void dispose() {
    tanggalController.dispose();
    super.dispose();
  }

  Future<void> fetchData(String? kategori, String? tanggal) async {
    try {
      String url = 'http://localhost/apielectrocare/select_laporan.php';
      if (kategori == null && tanggal == null) {
        url = 'http://localhost/apielectrocare/select_laporan.php';
      } else {
        url += '?kategori=$kategori&tanggal=$tanggal';
      }

      final response = await http.get(Uri.parse(url));

      // Log respons untuk debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            results = data['data'];
          });
        } else {
          _showErrorDialog(context, data['message']);
        }
      } else {
        _showErrorDialog(context, 'Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog(context, 'Terjadi kesalahan: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kesalahan'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Laporan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFF1515),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Pemasukkan', child: Text('Pemasukkan')), //samain sama database
                      DropdownMenuItem(value: 'Pengeluaran', child: Text('Pengeluaran')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedKategori = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    onTap: () => _selectDate(context, tanggalController),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                      hintText: selectedTanggal != null
                          ? "${DateFormat('yyyy-MM-dd').format(DateTime.parse(selectedTanggal!))}"
                          : 'Pilih Tanggal',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (selectedKategori != null && selectedTanggal != null) {
                      fetchData(selectedKategori!, selectedTanggal!);
                      setState(() {
                        selectedKategori = null;
                        selectedTanggal = null;
                      });
                    } else {
                      _showErrorDialog(context, 'Silakan pilih kategori dan tanggal.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF1515),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Filter'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Hasil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  return _buildTransactionItem(
                    item['kategori'],
                    item['nominal'],
                    item['tanggal'],
                    item['keterangan'],
                    item['id'].toString(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String kategori, dynamic nominal, String tanggal, String keterangan, String id) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white,
      elevation: 4,
      child: ListTile(
        title: Text(kategori),
        subtitle: Text('$keterangan\nTanggal: $tanggal'),
        trailing: Text(
          'Rp ${NumberFormat("#,###").format(int.parse(nominal.toString()))}',
          style: TextStyle(
            color: kategori == 'pemasukkan' ? Colors.green : Colors.red,
          ),
        ),
        onTap: () => _showTransactionOptions(context, kategori, nominal, tanggal, keterangan, id),
      ),
    );
  }

  void _showTransactionOptions(BuildContext context, String kategori, dynamic nominal, String tanggal, String keterangan, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pilih Aksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Detail'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showTransactionDetail(context, kategori, nominal, tanggal, keterangan);
              },
            ),
            ListTile(
              title: const Text('Ubah'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showUpdateDialog(context, id, kategori, nominal, tanggal, keterangan);
              },
            ),
            ListTile(
              title: const Text('Hapus'),
              onTap: () {
                Navigator.of(ctx).pop();
                _deleteTransaction(context, id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, String kategori, dynamic nominal, String tanggal, String keterangan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Detail Transaksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Kategori: $kategori'),
            Text('Nominal: Rp ${NumberFormat("#,###").format(int.parse(nominal.toString()))}'),
            Text('Tanggal: $tanggal'),
            Text('Keterangan: $keterangan'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        selectedTanggal = picked.toIso8601String();
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showUpdateDialog(BuildContext context, String id, String kategori, dynamic nominal, String tanggal, String keterangan) {
    final TextEditingController kategoriController = TextEditingController(text: kategori);
    final TextEditingController nominalController = TextEditingController(text: nominal.toString());
    final TextEditingController tanggalController = TextEditingController();
    final TextEditingController keteranganController = TextEditingController(text: keterangan);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Transaksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: kategoriController,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            TextField(
              controller: nominalController,
              decoration: const InputDecoration(labelText: 'Nominal'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: tanggalController,
              decoration: const InputDecoration(labelText: 'Tanggal'),
              readOnly: true,
              onTap: () => _selectDate(context, tanggalController),
            ),
            TextField(
              controller: keteranganController,
              decoration: const InputDecoration(labelText: 'Keterangan'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (kategoriController.text.isNotEmpty && nominalController.text.isNotEmpty && tanggalController.text.isNotEmpty && keteranganController.text.isNotEmpty) {
                _updateTransaction(id, kategoriController.text, nominalController.text, tanggalController.text, keteranganController.text);
                Navigator.of(ctx).pop();
              } else {
                _showErrorDialog(context, 'Semua field harus diisi.');
              }
            },
            child: const Text('Simpan'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTransaction(String id, String kategori, String nominal, String tanggal, String keterangan) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/apielectrocare/update_laporan.php'),
        body: {
          'id': id,
          'kategori': kategori,
          'nominal': nominal,
          'tanggal': tanggal,
          'keterangan': keterangan,
        },
      );

      // Log respons untuk debugging
      print('Update Response status: ${response.statusCode}');
      print('Update Response body: ${response.body}');

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          selectedKategori = null;
          selectedTanggal = null;
          results.clear();
        });
      } else {
        _showErrorDialog(context, data['message']);
      }
    } catch (e) {
      _showErrorDialog(context, 'Terjadi kesalahan: $e');
    }
  }

  Future<void> _deleteTransaction(BuildContext context, String id) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/apielectrocare/delete_laporan.php'),
        body: {'id': id},
      );

      // Log response for debugging
      print('Delete Response status: ${response.statusCode}');
      print('Delete Response body: ${response.body}');

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          results.removeWhere((item) => item['id'].toString() == id);
        });
      } else {
        _showErrorDialog(context, data['message']);
      }
    } catch (e) {
      _showErrorDialog(context, 'Terjadi kesalahan: $e');
    }
  }
}
