import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/trip_provider.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<TripProvider>().tripHistory;

    if (history.isEmpty) {
      return const Center(child: Text('No saved trips yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final trip = history[index];
        final formattedDate = DateFormat.yMMMd().format(trip.date);
        final duration = Duration(seconds: trip.durationInSeconds).toString().split('.').first.padLeft(8, "0");

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ExpansionTile(
            title: Text('Trip on $formattedDate'),
            subtitle: Text('${trip.distanceInKm.toStringAsFixed(2)} km | $duration'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Segments:', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (trip.segments.isEmpty) const Text('- No details provided.'),
                    for (var segment in trip.segments)
                      Text('- ${segment.mode ?? 'N/A'} for ${segment.purpose ?? 'N/A'}'),

                    const SizedBox(height: 12),
                    const Text('Companions:', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (trip.companions.isEmpty) const Text('- No companions.'),
                    for (var companion in trip.companions)
                      Text('- ${companion.name} (${companion.age}, ${companion.relation})'),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}