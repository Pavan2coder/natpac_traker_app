import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/trip_provider.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final starCount = context.watch<TripProvider>().starCount;
    final userBox = Hive.box('user');

    return ValueListenableBuilder(
      valueListenable: userBox.listenable(),
      builder: (context, box, widget) {
        final name = box.get('name', defaultValue: 'Username');
        final email = box.get('email', defaultValue: 'user@email.com');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
              const SizedBox(height: 16),
              Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(email, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              Card(
                color: Colors.yellow.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow.shade800, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$starCount Stars Earned', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const Text('Each saved trip earns you one star!'),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: (){
                  // Clear user box and navigate to login
                  box.clear();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50)
                ),
                child: const Text('Logout'),
              )
            ],
          ),
        );
      },
    );
  }
}