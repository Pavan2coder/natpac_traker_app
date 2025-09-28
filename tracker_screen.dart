import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../screens/complaints_screen.dart';
import '../screens/trip_summary_screen.dart';
import '../models/complaint_model.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  final List<LatLng> _polylinePoints = [];
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() => _currentPosition = LatLng(position.latitude, position.longitude));
        _mapController.move(_currentPosition!, 15.0);
      }
      const LocationSettings locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);
      _positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
            context.read<TripProvider>().updateTripProgress(position);
            if (mounted) {
              setState(() => _currentPosition = LatLng(position.latitude, position.longitude));
              if (context.read<TripProvider>().isTripActive) {
                _polylinePoints.add(_currentPosition!);
              }
              _mapController.move(_currentPosition!, 16.0);
            }
          });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition ?? const LatLng(10.0159, 76.3419), // Hyderabad, Telangana
            initialZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            PolylineLayer(
              polylines: [
                Polyline(points: _polylinePoints, color: Colors.blue, strokeWidth: 5.0),
              ],
            ),
            if (_currentPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition!,
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.my_location, color: Colors.blue, size: 30.0),
                  ),
                ],
              ),
          ],
        ),
        if (tripProvider.isTripActive)
          _buildActiveTripUI(context)
        else
          _buildStartTripUI(context),
      ],
    );
  }

  Widget _buildStartTripUI(BuildContext context) {
    return Positioned(
      bottom: 30, left: 60, right: 60,
      child: ElevatedButton(
        onPressed: () {
          setState(() => _polylinePoints.clear());
          context.read<TripProvider>().startTrip();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('Start Trip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildActiveTripUI(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final activeComplaint = tripProvider.activeTripComplaint;

    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard('Distance', '${tripProvider.tripDistanceInKm.toStringAsFixed(2)} km'),
                        _buildStatCard('Duration', tripProvider.formattedDuration),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLiveTrackingDetails(),
                    if (activeComplaint != null)
                      _buildComplaintNotification(activeComplaint),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(LucideIcons.siren, size: 18),
                        label: const Text('File a Complaint'),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ComplaintsScreen(),
                          ));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 30),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // This is the corrected navigation: push, not pushReplacement.
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const TripSummaryScreen(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('End Trip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLiveTrackingDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Live Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.check_circle, 'Movement Detected', Colors.green),
          const SizedBox(height: 4),
          _buildDetailRow(Icons.location_on, 'Location updates every 10 meters', Colors.green),
          const SizedBox(height: 4),
          _buildDetailRow(Icons.timer_off, 'Auto-stop at 20 min stationary', Colors.red),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildComplaintNotification(Complaint complaint) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.flag, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Complaint Filed', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900)),
                Text(complaint.category, style: TextStyle(color: Colors.red.shade800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}