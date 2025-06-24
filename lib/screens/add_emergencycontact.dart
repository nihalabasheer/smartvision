import 'package:flutter/material.dart';
import 'package:smartvision/services/contact_store.dart';// Add this import


class AddEmergencyContactPage extends StatefulWidget {
  const AddEmergencyContactPage({super.key});

  @override
  State<AddEmergencyContactPage> createState() => _AddEmergencyContactPageState();
}

class _AddEmergencyContactPageState extends State<AddEmergencyContactPage> {
  final List<Map<String, TextEditingController>> _contacts = [];

  final Color mainBlue = const Color(0xFF3A4D8A);

  void _addContactField() {
    setState(() {
      _contacts.add({
        'name': TextEditingController(),
        'phone': TextEditingController(),
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _addContactField(); // Start with one contact
  }

  @override
  void dispose() {
    for (var contact in _contacts) {
      contact['name']?.dispose();
      contact['phone']?.dispose();
    }
    super.dispose();
  }

  Widget _buildContactCard(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Contact ${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: mainBlue,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contacts[index]['name'],
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contacts[index]['phone'],
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _saveContacts() async {
    await ContactStore.saveContacts(_contacts.map((c) => {
      'name': c['name']!.text.trim(),
      'phone': c['phone']!.text.trim(),
    }).toList());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contacts saved successfully')),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Emergency Contacts"),
        centerTitle: true,
        backgroundColor: mainBlue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) => _buildContactCard(index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _addContactField,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Another Contact"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _saveContacts,
                  icon: const Icon(Icons.save),
                  label: const Text("Save Contacts"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
