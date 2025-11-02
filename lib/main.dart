import 'package:aplikasi_inventarisasi/pages/edit_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String endpoint =
      "https://script.google.com/macros/s/AKfycbzJ5Cah6rs_RPsefgcet9E28ZRMefESc2aZROpHBFuEyErHBTwSY1wIhe803G9JQrz83Q/exec";

  @override
  Widget build(BuildContext context) {
    ApiService.endpoint = endpoint;

    return MaterialApp(
      title: 'Inventaris RFID',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const EntryPoint(),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class EntryPoint extends StatefulWidget {
  const EntryPoint({Key? key}) : super(key: key);
  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  bool _loading = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (mounted) {
        setState(() {
          _loggedIn = isLoggedIn;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loggedIn = false;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _loggedIn ? const HomePage() : const LoginPage();
  }
}