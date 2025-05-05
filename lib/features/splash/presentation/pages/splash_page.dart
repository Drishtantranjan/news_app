import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool? isDark;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _navigateToHome();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme_mode');
    setState(() {
      if (theme == 'dark') {
        isDark = true;
      } else if (theme == 'light') {
        isDark = false;
      } else {
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        isDark = brightness == Brightness.dark;
      }
    });
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/news-list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ?? false ? Color(0xFF171A1B) : Colors.grey[50],
      body: Center(
        child: Image.asset(
          isDark??false ? 'assets/logo_dark.png' : 'assets/logo_white.png',
          width: 300,
          height: 300,
        ),
      ),
    );
  }
}