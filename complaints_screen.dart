import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/complaint_model.dart';
import 'package:intl/intl.dart';
import '../providers/trip_provider.dart';
import 'package:provider/provider.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});
  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final _complaintBox = Hive.box<Complaint>('complaints');
  final _descriptionController = TextEditingController();
  String _category = 'Road Block';
  String _priority = 'Medium';

  void _submitComplaint() {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a description.'), backgroundColor: Colors.red)
      );
      return;
    }

    final newComplaint = Complaint()
      ..date = DateTime.now()
      ..category = _category
      ..priority = _priority
      ..description = _descriptionController.text;

    _complaintBox.add(newComplaint);

    // If a trip is active, notify the provider and go back to the map
    final tripProvider = context.read<TripProvider>();
    if (tripProvider.isTripActive) {
      tripProvider.logComplaintForActiveTrip(newComplaint);
      Navigator.of(context).pop(); // Go back to the tracker screen
    } else {
      _descriptionController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint Submitted!'), backgroundColor: Colors.green)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('File a Complaint', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _category,
              items: ['Road Block', 'Traffic Jam', 'Bus Delay', 'Poor Road Condition']
                  .map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
              onChanged: (value) => setState(() => _category = value!),
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPriorityRadio('High'),
                _buildPriorityRadio('Medium'),
                _buildPriorityRadio('Low'),
              ],
            ),
            const SizedBox(height: 16),
            TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitComplaint,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Submit Complaint'),
            ),
            const Divider(height: 40),
            const Text('Complaint History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: _complaintBox.listenable(),
              builder: (context, Box<Complaint> box, _) {
                final complaints = box.values.toList().reversed.toList();
                if (complaints.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('No complaints filed yet.')));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(complaint.category),
                        subtitle: Text(complaint.description),
                        trailing: Text(DateFormat.yMd().format(complaint.date)),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityRadio(String title) {
    return Row(
      children: [
        Radio<String>(
          value: title,
          groupValue: _priority,
          onChanged: (value) => setState(() => _priority = value!),
        ),
        Text(title),
      ],
    );
  }
}