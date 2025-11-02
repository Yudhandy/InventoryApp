import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // assigned from main
  static String endpoint = "";

  // fetch all records
  static Future<List<dynamic>> fetchAll() async {
    final uri = Uri.parse('$endpoint?action=getAll');
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      try {
        final List<dynamic> j = json.decode(res.body);
        return j;
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  // update name + keterangan for a UID
  static Future<bool> updateNama(String uid, String nama, String keterangan) async {
    final uri = Uri.parse(
        '$endpoint?action=updateNama&uid=${Uri.encodeComponent(uid)}&nama=${Uri.encodeComponent(nama)}&keterangan=${Uri.encodeComponent(keterangan)}');
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    return res.statusCode == 200 && res.body.trim() == 'OK';
  }

  // add uid (used by ESP) - not needed here but kept
  static Future<bool> addUID(String uid) async {
    final uri = Uri.parse('$endpoint?action=addUID&uid=${Uri.encodeComponent(uid)}&status=baru');
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    return res.statusCode == 200;
  }

  // delete single by uid
  static Future<bool> deleteUID(String uid) async {
    final uri = Uri.parse('$endpoint?action=delete&uid=${Uri.encodeComponent(uid)}');
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    return res.statusCode == 200 && res.body.trim() == 'OK';
  }

  // delete all
  static Future<bool> deleteAll() async {
    final uri = Uri.parse('$endpoint?action=deleteAll');
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    return res.statusCode == 200 && res.body.trim() == 'OK';
  }
}