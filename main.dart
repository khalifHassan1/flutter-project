import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HouseRentingApp());
}

class HouseRentingApp extends StatelessWidget {
  const HouseRentingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'House Renting App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const LoginPage(),
    );
  }
}
