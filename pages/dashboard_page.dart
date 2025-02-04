import 'package:flutter/material.dart';
import 'create_user_page.dart';
import 'house_page.dart';
import 'person_house_page.dart';
import 'person_page.dart';
import 'login_page.dart';
import '../utils/db_helper.dart';

class SummaryPage extends StatelessWidget {
  final bool isAdmin;
  const SummaryPage({Key? key, required this.isAdmin}) : super(key: key);

  Future<Map<String, int>> _fetchSummaryData() async {
    final dbHelper = DBHelper();
    var houses = await dbHelper.getHouses();
    var persons = await dbHelper.getPersons();
    var links = await dbHelper.getPersonHouse();
    int usersCount = 0;
    if (isAdmin) {
      var users = await dbHelper.getUsers();
      usersCount = users.length;
    }

    return {
      'houses': houses.length,
      'persons': persons.length,
      'links': links.length,
      'users': usersCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _fetchSummaryData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading summary data'));
        }

        final data = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard Summary',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildSummaryCard('Houses', data['houses']!, Icons.house, Colors.blue),
                    _buildSummaryCard('Persons', data['persons']!, Icons.person, Colors.green),
                    _buildSummaryCard('Links', data['links']!, Icons.link, Colors.orange),
                    if (isAdmin)
                      _buildSummaryCard('Users', data['users']!, Icons.admin_panel_settings, Colors.red),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, int count, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      shadowColor: color.withOpacity(0.4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(colors: [color.withOpacity(0.8), color.withOpacity(0.6)]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 4),
            Text('$count', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  final String username;
  final bool isAdmin;

  const DashboardPage({Key? key, required this.username, required this.isAdmin})
      : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      SummaryPage(isAdmin: widget.isAdmin),
      const HousePage(),
      const PersonPage(),
      const PersonHousePage(),
      if (widget.isAdmin) const CreateUserPage(),
    ];
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Summary'),
      const BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Houses'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Persons'),
      const BottomNavigationBarItem(icon: Icon(Icons.link), label: 'Links'),
    ];
    if (widget.isAdmin) {
      navItems.add(
        const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Users'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/profile.png'), // Add profile image
              radius: 16,
            ),
            const SizedBox(width: 8),
            Text('Dashboard - ${widget.username}', style: const TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Create User',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateUserPage()));
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: navItems,
      ),
    );
  }
}
