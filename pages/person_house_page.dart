import 'package:flutter/material.dart';
import '../utils/db_helper.dart';

class PersonHousePage extends StatefulWidget {
  const PersonHousePage({Key? key}) : super(key: key);

  @override
  State<PersonHousePage> createState() => _PersonHousePageState();
}

class _PersonHousePageState extends State<PersonHousePage> {
  final DBHelper _dbHelper = DBHelper();

  List<Map> _personHouse = [];
  List<Map> _persons = [];
  List<Map> _houses = [];

  int? _selectedPersonId;
  int? _selectedHouseId;

  @override
  void initState() {
    super.initState();
    _fetchPersonHouse();
    _fetchPersons();
    _fetchHouses();
  }

  Future<void> _fetchPersonHouse() async {
    var data = await _dbHelper.getPersonHouse();
    setState(() {
      _personHouse = data;
    });
  }

  Future<void> _fetchPersons() async {
    var data = await _dbHelper.getPersons();
    setState(() {
      _persons = data;
    });
  }

  Future<void> _fetchHouses() async {
    var data = await _dbHelper.getHouses();
    setState(() {
      _houses = data;
    });
  }

  /// Displays a bottom sheet form to link a person to a house.
  void _showPersonHouseBottomSheet() {
    final _formKey = GlobalKey<FormState>();

    // Reset selections when opening the form.
    _selectedPersonId = null;
    _selectedHouseId = null;

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
              right: 20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Link Person to House',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Dropdown for selecting a person.
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Select Person',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    items: _persons.map((person) {
                      return DropdownMenuItem<int>(
                        value: person['id'] as int,
                        child: Text(person['name']),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a person';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _selectedPersonId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Dropdown for selecting a house.
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Select House',
                      prefixIcon: Icon(Icons.house),
                      border: OutlineInputBorder(),
                    ),
                    items: _houses.map((house) {
                      return DropdownMenuItem<int>(
                        value: house['id'] as int,
                        child: Text(house['address']),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a house';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _selectedHouseId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          Map<String, dynamic> data = {
                            'personId': _selectedPersonId,
                            'houseId': _selectedHouseId,
                          };
                          await _dbHelper.insertPersonHouse(data);
                          Navigator.pop(context);
                          _fetchPersonHouse();
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

  /// Deletes a person-house link with confirmation.
  void _deletePersonHouse(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Link'),
        content: const Text('Are you sure you want to delete this link?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _dbHelper.deletePersonHouse(id);
              _fetchPersonHouse();
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
      appBar: AppBar(
        title: const Text('Person-House Linking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              _fetchPersonHouse();
              _fetchPersons();
              _fetchHouses();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchPersonHouse();
          await _fetchPersons();
          await _fetchHouses();
        },
        child: _personHouse.isEmpty
            ? ListView(
                // Enables pull-to-refresh when the list is empty.
                children: const [
                  SizedBox(
                    height: 300,
                    child: Center(child: Text('No links found')),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(10),
                itemCount: _personHouse.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  var item = _personHouse[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: const Icon(Icons.link, color: Colors.blueAccent),
                      title: Text('Person: ${item['name']}'),
                      subtitle: Text('House: ${item['address']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePersonHouse(item['id']),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPersonHouseBottomSheet,
        tooltip: 'Link Person to House',
        icon: const Icon(Icons.add),
        label: const Text('Add Link'),
      ),
    );
  }
}
