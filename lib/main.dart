import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/expense_model.dart';
import 'screens/home_screen.dart';
import 'screens/transaction_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/transaction_list_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ExpenseModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('username');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Chi Tiêu',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
              future: checkLogin(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                }
                return snapshot.data! ? const HomePage() : const LoginScreen();
              },
            ),
        '/transactions': (context) => const TransactionListScreen(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    TransactionScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle), label: 'Giao dịch'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Thống kê'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}