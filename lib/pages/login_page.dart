import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditPage extends StatefulWidget {
  final Map item;
  const EditPage({Key? key, required this.item}) : super(key: key);

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController _nama;
  late TextEditingController _ket;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.item['nama']?.toString() ?? '');
    _ket = TextEditingController(text: widget.item['keterangan']?.toString() ?? '');
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final ok = await ApiService.updateNama(widget.item['uid'].toString(), _nama.text.trim(), _ket.text.trim());
    setState(() => _loading = false);
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Edit Data')),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _nama, decoration: const InputDecoration(labelText: 'Nama Barang')),
                const SizedBox(height:12),
                TextField(controller: _ket, decoration: const InputDecoration(labelText: 'Keterangan')),
                const SizedBox(height:24),
                _loading ? const CircularProgressIndicator() : ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Simpan'))
              ],
            ),
        ),
        );
    }
}