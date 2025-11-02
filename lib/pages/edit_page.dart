import 'package:aplikasi_inventarisasi/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'edit_page.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> data = [];
  bool loading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.fetchAll();
      if (mounted) {
        setState(() {
          data = result;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          data = [];
          loading = false;
          errorMessage = 'Gagal memuat data: ${e.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return '-';

    try {
      final dt = DateTime.parse(timestamp.toString());
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return timestamp.toString();
    }
  }

  Future<void> _logout() async {
    final confirm = await _showConfirmDialog(
      title: 'Logout',
      content: 'Yakin ingin keluar dari aplikasi?',
      confirmText: 'Logout',
    );

    if (confirm == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('isLoggedIn');

        if (!mounted) return;

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
              (route) => false,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logout: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteItem(String uid) async {
    final confirm = await _showConfirmDialog(
      title: 'Hapus Item',
      content: 'Yakin ingin menghapus item dengan UID: $uid?',
      confirmText: 'Hapus',
      isDestructive: true,
    );

    if (confirm == true) {
      try {
        final success = await ApiService.deleteUID(uid);
        if (success) {
          await _load();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item berhasil dihapus'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          throw Exception('Gagal menghapus item');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error menghapus: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAllItems() async {
    final confirm = await _showConfirmDialog(
      title: 'Hapus Semua Data',
      content: 'PERINGATAN: Ini akan menghapus SEMUA data inventaris!\n\nTindakan ini tidak dapat dibatalkan. Yakin ingin melanjutkan?',
      confirmText: 'Hapus Semua',
      isDestructive: true,
    );

    if (confirm == true) {
      try {
        final success = await ApiService.deleteAll();
        if (success) {
          await _load();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Semua data berhasil dihapus'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          throw Exception('Gagal menghapus semua data');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error menghapus semua data: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  Future<void> _editItem(Map<String, dynamic> item) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPage(item: item),
      ),
    );

    if (result == true) {
      await _load();
    }
  }

  Widget _buildItemCard(Map<String, dynamic> item, int index) {
    final uid = item['uid']?.toString() ?? '';
    final nama = item['nama']?.toString() ?? '';
    final keterangan = item['keterangan']?.toString() ?? '';
    final waktu = item['waktu'];
    final status = item['status']?.toString() ?? '';
    final isBaru = status.toLowerCase() == 'baru';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isBaru ? Colors.orange : Colors.green,
          child: Icon(
            isBaru ? Icons.new_releases_rounded : Icons.check_circle_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          nama.isEmpty ? 'Belum ada nama' : nama,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: nama.isEmpty ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'UID: $uid',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
            if (keterangan.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Ket: $keterangan',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
            if (waktu != null) ...[
              const SizedBox(height: 2),
              Text(
                'Waktu: ${_formatDateTime(waktu)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editItem(item);
                break;
              case 'delete':
                _deleteItem(uid);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Hapus'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventaris Barang',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
          if (data.isNotEmpty)
            IconButton(
              onPressed: _deleteAllItems,
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Hapus Semua',
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: data.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (context, index) =>
              _buildItemCard(data[index], index),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loading ? null : _load,
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data inventaris',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tarik ke bawah untuk refresh atau\nscan RFID tag untuk menambah data',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}