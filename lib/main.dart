import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/expense_model.dart';
import 'screens/home_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/transaction_list_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => ExpenseModel(), child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  Color primaryColor = Colors.blue;

  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('username');
  }

  void _toggleTheme(bool value) {
    setState(() => isDarkMode = value);
  }

  void _changeColor(Color color) {
    setState(() => primaryColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Chi Tiêu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: primaryColor,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        useMaterial3: true,
      ),
      routes: {'/transaction-list': (context) => const TransactionListScreen()},
      home: FutureBuilder<bool>(
        future: checkLogin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == true) {
            return HomePage(
              onThemeChanged: _toggleTheme,
              onColorChanged: _changeColor,
              isDarkMode: isDarkMode,
              primaryColor: primaryColor,
            );
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final void Function(bool) onThemeChanged;
  final void Function(Color) onColorChanged;
  final bool isDarkMode;
  final Color primaryColor;

  const HomePage({
    super.key,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.isDarkMode,
    required this.primaryColor,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const WalletScreen(),
      const StatisticsScreen(),
      ProfileScreen(
        onThemeChanged: widget.onThemeChanged,
        onColorChanged: widget.onColorChanged,
        isDarkMode: widget.isDarkMode,
        primaryColor: widget.primaryColor,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Ví tiền',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
