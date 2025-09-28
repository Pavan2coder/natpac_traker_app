import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../providers/trip_provider.dart';
import '../screens/tracker_screen.dart';
import '../screens/history_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/complaints_screen.dart';
import '../screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    TrackerScreen(),
    HistoryScreen(),
    StatisticsScreen(),
    ComplaintsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NATPAC Tracker'),
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              backgroundColor: Colors.amber,
              avatar: const Icon(LucideIcons.star, color: Colors.white, size: 18),
              label: Text(
                '${context.watch<TripProvider>().starCount}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // --- STYLE UPDATES ---
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        // --- END STYLE UPDATES ---
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(LucideIcons.map), label: 'Tracker'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.chart_bar), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.siren), label: 'Complaints'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}