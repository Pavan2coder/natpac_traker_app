import 'package:flutter/material.dart';
import '../providers/trip_provider.dart';
import 'package:provider/provider.dart';
import '../models/trip_model.dart'; // <-- This is the missing import

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<TripProvider>().tripHistory;

    if (history.isEmpty) {
      return const Center(child: Text('Complete a trip to see statistics.'));
    }

    // --- Statistics Calculation ---
    final totalTrips = history.length;
    final totalDistance = history.fold<double>(0, (prev, trip) => prev + trip.distanceInKm);
    final totalSeconds = history.fold<int>(0, (prev, trip) => prev + trip.durationInSeconds);
    final totalHours = totalSeconds ~/ 3600; // Use integer division
    final totalMinutes = (totalSeconds % 3600) ~/ 60;

    final modeCounts = <String, int>{};
    for (var trip in history) {
      for (var segment in trip.segments) {
        if (segment.mode != null) {
          modeCounts[segment.mode!] = (modeCounts[segment.mode] ?? 0) + 1;
        }
      }
    }
    final totalModes = modeCounts.values.fold(0, (prev, count) => prev + count);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trip Statistics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Trips', totalTrips.toString(), Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Total Distance', '${totalDistance.toStringAsFixed(2)} km', Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Total Time', '${totalHours}h ${totalMinutes}m', Colors.purple)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Mode Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (modeCounts.isEmpty) const Text('No mode data available.'),
          for (var entry in modeCounts.entries)
            _buildBar(entry.key, entry.value, totalModes),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, int count, int total) {
    final percentage = total > 0 ? (count / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 20,
                backgroundColor: Colors.grey[200],
              ),
            ),
          ),
          SizedBox(width: 60, child: Text(' ${(percentage * 100).toStringAsFixed(0)}%', textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}