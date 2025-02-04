import 'package:flutter/material.dart';
import '../utils/db_helper.dart';

class PersonPage extends StatefulWidget {
  const PersonPage({Key? key}) : super(key: key);

  @override
  State<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  final DBHelper _dbHelper = DBHelper();
  List<Map> _persons = [];

  @override
  void initState() {
    super.initState();
    _fetchPersons();
  }

  /// Fetch persons from the database and update the list.
  Future<void> _fetchPersons() async {
    var data = await _dbHelper.getPersons();
    setState(() {
      _persons = data;
    });
  }

  /// Opens a bottom sheet for adding or editing a person.
  void _showPersonBottomSheet({Map? person}) {
    final _formKey = GlobalKey<FormState>();

    // Initialize form field values (if editing, use the existing values)
    String name = person != null ? person['name'] ?? '' : '';
    String phone = person != null ? person['phone'] ?? '' : '';
    String age = person != null ? person['age']?.toString() ?? '' : '';
    String gender = person != null ? person['gender'] ?? '' : '';
    String email = person != null ? person['email'] ?? '' : '';
    String occupation = person != null ? person['occupation'] ?? '' : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      person == null ? 'Add Person' : 'Edit Person',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Name Field
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                    onSaved: (value) => name = value!,
                  ),
                  const SizedBox(height: 15),
                  // Phone Field
                  TextFormField(
                    initialValue: phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                    onSaved: (value) => phone = value!,
                  ),
                  const SizedBox(height: 15),
                  // Age Field
                  TextFormField(
                    initialValue: age,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                    onSaved: (value) => age = value!,
                  ),
                  const SizedBox(height: 15),
                  // Gender Field
                  TextFormField(
                    initialValue: gender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.wc),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                    onSaved: (value) => gender = value!,
                  ),
                  const SizedBox(height: 15),
                  // Email Field
                  TextFormField(
                    initialValue: email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                    onSaved: (value) => email = value!,
                  ),
                  const SizedBox(height: 15),
                  // Occupation Field
                  TextFormField(
                    initialValue: occupation,
                    decoration: const InputDecoration(
                      labelText: 'Occupation',
                      prefixIcon: Icon(Icons.work),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                    onSaved: (value) => occupation = value!,
                  ),
                  const SizedBox(height: 20),
                  // Save button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          // Prepare data with proper types. Parse age to int.
                          Map<String, dynamic> data = {
                            'name': name,
                            'phone': phone,
                            'age': int.tryParse(age) ?? 0,
                            'gender': gender,
                            'email': email,
                            'occupation': occupation,
                          };

                          if (person == null) {
                            // Insert new person
                            await _dbHelper.insertPerson(data);
                          } else {
                            // Update existing person with ID
                            data['id'] = person['id'];
                            await _dbHelper.updatePerson(data);
                          }
                          Navigator.pop(context);
                          _fetchPersons();
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Delete a person with a confirmation alert.
  void _deletePerson(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Person'),
        content: const Text('Are you sure you want to delete this person?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cancel deletion
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              await _dbHelper.deletePerson(id);
              _fetchPersons();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Person Management'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPersons,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPersons,
        child: _persons.isEmpty
            ? ListView(
                // Allow pull-to-refresh when the list is empty.
                children: const [
                  SizedBox(
                    height: 300,
                    child: Center(child: Text('No persons found')),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(10),
                itemCount: _persons.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  var person = _persons[index];

                  // Create initials for avatar
                  String initials = '';
                  if (person['name'] != null && person['name'].toString().isNotEmpty) {
                    List<String> names = person['name'].toString().split(' ');
                    initials = names.length > 1
                        ? '${names[0][0]}${names[1][0]}'
                        : names[0][0];
                  }

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              initials.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  person['name'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.phone,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(person['phone'] ?? ''),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text('Age: ${person['age']}'),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.wc,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text('Gender: ${person['gender']}'),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.email,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Flexible(child: Text(person['email'] ?? '')),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.work,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(person['occupation'] ?? ''),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    _showPersonBottomSheet(person: person),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deletePerson(person['id']),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPersonBottomSheet(),
        label: const Text('Add Person'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
