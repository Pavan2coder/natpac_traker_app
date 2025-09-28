import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:natpac_tracker_app/providers/trip_provider.dart';
import '../models/complaint_model.dart';
import 'package:provider/provider.dart';
import 'providers/trip_provider.dart';
import '../screens/splash_screen.dart';
import '../models/trip_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TripAdapter());
  Hive.registerAdapter(TripSegmentAdapter());
  Hive.registerAdapter(ComplaintAdapter());

  await Hive.openBox<Trip>('trips');
  await Hive.openBox<Complaint>('complaints');
  await Hive.openBox('user');

  runApp(
    ChangeNotifierProvider(
      create: (context) => TripProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NATPAC Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}