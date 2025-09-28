import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../models/trip_model.dart';

class UITripSegment {
  String? selectedMode;
  String? selectedPurpose;
}

class UICompanion {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String relation = 'Child';
}

class TripSummaryScreen extends StatefulWidget {
  const TripSummaryScreen({super.key});
  @override
  State<TripSummaryScreen> createState() => _TripSummaryScreenState();
}

class _TripSummaryScreenState extends State<TripSummaryScreen> {
  final List<UITripSegment> _segments = [];
  final List<UICompanion> _companions = [];
  bool _hasCompanions = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    if (_segments.isEmpty) {
      _segments.add(UITripSegment());
    }
    _validateForm();
  }

  @override
  void dispose() {
    for (var companion in _companions) {
      companion.nameController.dispose();
      companion.ageController.dispose();
    }
    super.dispose();
  }

  void _validateForm() {
    bool isValid = _segments.every((s) => s.selectedMode != null && s.selectedPurpose != null);
    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  void _onSaveOrSkip(BuildContext context, {bool shouldSave = false}) {
    final tripProvider = context.read<TripProvider>();
    if (shouldSave && _isFormValid) {
      final segmentsToSave = _segments.map((s) => TripSegment()
        ..mode = s.selectedMode
        ..purpose = s.selectedPurpose).toList();

      final companionsToSave = _companions.map((c) => Companion()
        ..name = c.nameController.text
        ..age = c.ageController.text
        ..relation = c.relation).toList();

      tripProvider.saveTrip(segmentsToSave, companionsToSave);
    } else {
      tripProvider.skipTrip();
    }
    // This is the corrected navigation: pop, which closes the screen.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Summary'),
        automaticallyImplyLeading: false, // No back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Your trip is complete! Please provide a few more details.", style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 24),
            Column(
              children: [
                for (int i = 0; i < _segments.length; i++)
                  _buildSegmentCard(i),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Another Segment"),
              onPressed: () {
                setState(() => _segments.add(UITripSegment()));
                _validateForm();
              },
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
              child: CheckboxListTile(
                title: const Text("I travelled with companions"),
                value: _hasCompanions,
                onChanged: (bool? value) {
                  setState(() {
                    _hasCompanions = value!;
                    if (_hasCompanions && _companions.isEmpty) {
                      _companions.add(UICompanion());
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (_hasCompanions) _buildCompanionsSection(),
            if (!_isFormValid)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Center(
                  child: Text(
                    'Please select a mode and purpose for each segment to save.',
                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(LucideIcons.star, size: 18),
                    label: const Text("Save Trip & Get 1"),
                    onPressed: _isFormValid ? () => _onSaveOrSkip(context, shouldSave: true) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => _onSaveOrSkip(context),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text("Skip"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentCard(int index) {
    UITripSegment currentSegment = _segments[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Trip Segment ${index + 1}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (index > 0)
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red.shade300),
                    onPressed: () {
                      setState(() => _segments.removeAt(index));
                      _validateForm();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Mode of Transport", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0, runSpacing: 8.0,
              children: [
                _buildSelectableIcon(index, LucideIcons.bus, "Bus", "mode", currentSegment.selectedMode == "Bus"),
                _buildSelectableIcon(index, LucideIcons.car, "Car", "mode", currentSegment.selectedMode == "Car"),
                _buildSelectableIcon(index, LucideIcons.bike, "Bike", "mode", currentSegment.selectedMode == "Bike"),
                _buildSelectableIcon(index, LucideIcons.train_front, "train", "mode", currentSegment.selectedMode == "Train"),
                _buildSelectableIcon(index, LucideIcons.tree_palm, "other", "mode", currentSegment.selectedMode == "other"),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Purpose of Trip", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0, runSpacing: 8.0,
              children: [
                _buildSelectableIcon(index, LucideIcons.briefcase, "Work", "purpose", currentSegment.selectedPurpose == "Work"),
                _buildSelectableIcon(index, LucideIcons.graduation_cap, "School", "purpose", currentSegment.selectedPurpose == "School"),
                _buildSelectableIcon(index, LucideIcons.shopping_cart, "Shopping", "purpose", currentSegment.selectedPurpose == "Shopping"),
                _buildSelectableIcon(index, LucideIcons.house, "house", "purpose", currentSegment.selectedPurpose == "House"),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableIcon(int index, IconData icon, String label, String group, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (group == "mode") {
            _segments[index].selectedMode = label;
          } else {
            _segments[index].selectedPurpose = label;
          }
        });
        _validateForm();
      },
      child: Container(
        width: 70, padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.blue.shade800 : Colors.black54),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanionsSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          for (int i = 0; i < _companions.length; i++)
            _buildCompanionInputCard(i),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add Companion"),
            onPressed: () => setState(() => _companions.add(UICompanion())),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              foregroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanionInputCard(int index) {
    UICompanion currentCompanion = _companions[index];
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: currentCompanion.nameController, decoration: const InputDecoration(labelText: 'Name'))),
                const SizedBox(width: 8),
                SizedBox(width: 80, child: TextField(controller: currentCompanion.ageController, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                IconButton(onPressed: () => setState(() => _companions.removeAt(index)), icon: Icon(Icons.close, color: Colors.red.shade300)),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: currentCompanion.relation,
              items: ['Child', 'Parent', 'Friend', 'Spouse', 'Other']
                  .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                  .toList(),
              onChanged: (value) => setState(() => currentCompanion.relation = value!),
              decoration: const InputDecoration(labelText: 'Relation'),
            ),
          ],
        ),
      ),
    );
  }
}