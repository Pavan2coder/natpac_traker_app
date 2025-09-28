import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import '../models/trip_model.dart';
import '../models/complaint_model.dart';

class TripProvider with ChangeNotifier {
  bool _isTripActive = false;
  Timer? _tripTimer;
  int _tripDurationInSeconds = 0;
  double _tripDistanceInKm = 0.0;
  Position? _lastPosition;

  // New variable to hold a complaint filed during the active trip
  Complaint? activeTripComplaint;

  final Box<Trip> _tripBox = Hive.box<Trip>('trips');
  List<Trip> _tripHistory = [];

  TripProvider() {
    _loadTripHistory();
  }

  // --- Getters ---
  bool get isTripActive => _isTripActive;
  List<Trip> get tripHistory => _tripHistory;
  int get starCount => _tripHistory.length;
  int get tripDurationInSeconds => _tripDurationInSeconds;
  double get tripDistanceInKm => _tripDistanceInKm;
  String get formattedDuration {
    final duration = Duration(seconds: _tripDurationInSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _loadTripHistory() {
    _tripHistory = _tripBox.values.toList().reversed.toList();
    notifyListeners();
  }

  void startTrip() {
    _isTripActive = true;
    _tripDurationInSeconds = 0;
    _tripDistanceInKm = 0.0;
    _lastPosition = null;
    activeTripComplaint = null; // Reset complaint on new trip
    _tripTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tripDurationInSeconds++;
      notifyListeners();
    });
    notifyListeners();
  }

  void updateTripProgress(Position newPosition) {
    if (_isTripActive) {
      if (_lastPosition != null) {
        double distanceInMeters = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          newPosition.latitude,
          newPosition.longitude,
        );
        _tripDistanceInKm += (distanceInMeters / 1000.0);
      }
      _lastPosition = newPosition;
      notifyListeners();
    }
  }

  // New method for the complaint screen to call
  void logComplaintForActiveTrip(Complaint complaint) {
    activeTripComplaint = complaint;
    notifyListeners();
  }

  Future<void> saveTrip(List<TripSegment> segments, List<Companion> companions) async {
    _isTripActive = false;
    _tripTimer?.cancel();

    final newTrip = Trip()
      ..date = DateTime.now()
      ..durationInSeconds = _tripDurationInSeconds
      ..distanceInKm = _tripDistanceInKm
      ..segments = segments
      ..companions = companions;

    await _tripBox.add(newTrip);
    _loadTripHistory();
  }

  void skipTrip() {
    _isTripActive = false;
    _tripTimer?.cancel();
    notifyListeners();
  }
}