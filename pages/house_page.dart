import 'package:flutter/material.dart';
import '../utils/db_helper.dart';

class HousePage extends StatefulWidget {
  const HousePage({Key? key}) : super(key: key);

  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  final DBHelper _dbHelper = DBHelper();
  List<Map> _houses = [];

  @override
  void initState() {
    super.initState();
    _fetchHouses();
  }

  /// Fetch houses from the database and update the list.
  Future<void> _fetchHouses() async {
    var data = await _dbHelper.getHouses();
    setState(() {
      _houses = data;
    });
  }

  /// Opens a bottom sheet for adding or editing a house.
  void _showHouseBottomSheet({Map? house}) {
    final _formKey = GlobalKey<FormState>();
    // Use existing values for editing, or default values for adding.
    String address = house != null ? house['address'] ?? '' : '';
    String price = house != null ? house['price']?.toString() ?? '' : '';
    String description = house != null ? house['description'] ?? '' : '';

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
                      house == null ? 'Add House' : 'Edit House',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Address Field
                  TextFormField(
                    initialValue: address,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.home),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                    onSaved: (value) => address = value!,
                  ),
                  const SizedBox(height: 15),
                  // Price Field
                  TextFormField(
                    initialValue: price,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                    onSaved: (value) => price = value!,
                  ),
                  const SizedBox(height: 15),
                  // Description Field
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                    onSaved: (value) => description = value!,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          Map<String, dynamic> data = {
                            'address': address,
                            'price': double.parse(price),
                            'description': description,
                          };

                          if (house == null) {
                            // Insert new house.
                            await _dbHelper.insertHouse(data);
                          } else {
                            // Update existing house (pass the id).
                            data['id'] = house['id'];
                            await _dbHelper.updateHouse(data);
                          }
                          Navigator.pop(context);
                          _fetchHouses();
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

  /// Deletes a house with a confirmation dialog.
  void _deleteHouse(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete House'),
        content: const Text('Are you sure you want to delete this house?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _dbHelper.deleteHouse(id);
              _fetchHouses();
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
        title: const Text('House Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHouses,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchHouses,
        child: _houses.isEmpty
            ? ListView(
                // Enables pull-to-refresh when the list is empty.
                children: const [
                  SizedBox(
                    height: 300,
                    child: Center(child: Text('No houses found')),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(10),
                itemCount: _houses.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  var house = _houses[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.house,
                              size: 40, color: Colors.blueAccent),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  house['address'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text('Price: \$${house['price']}'),
                                const SizedBox(height: 5),
                                Text('Description: ${house['description']}'),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue),
                                onPressed: () => _showHouseBottomSheet(house: house),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () => _deleteHouse(house['id']),
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
        onPressed: () => _showHouseBottomSheet(),
        label: const Text('Add House'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
