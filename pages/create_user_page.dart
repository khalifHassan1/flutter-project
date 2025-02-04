import 'package:flutter/material.dart';
import '../utils/db_helper.dart';
import '../pages/dashboard_page.dart';  // Update the path as needed

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({Key? key}) : super(key: key);

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isAdmin = false;
  final DBHelper _dbHelper = DBHelper();

  void _createUser() async {
  if (!_formKey.currentState!.validate()) return;
  _formKey.currentState!.save();

  Map<String, dynamic> userData = {
    'username': _username,
    'password': _password,
    'isAdmin': _isAdmin ? 1 : 0,
  };

  await _dbHelper.insertUser(userData);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('User created successfully')),
  );

  // Navigate back to the DashboardPage and refresh it
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => DashboardPage(username: "admin", isAdmin: true),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff6a11cb), Color(0xff2575fc)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Create New User',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                        onSaved: (value) => _username = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                        onSaved: (value) => _password = value!,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Admin Privileges'),
                        value: _isAdmin,
                        onChanged: (val) {
                          setState(() {
                            _isAdmin = val;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _createUser,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Create',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
