import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../screens/login_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final userBox = Hive.box('user');

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                userBox.put('name', nameController.text);
                userBox.put('email', emailController.text);
                userBox.put('password', passwordController.text);
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen())
                );
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white
              ),
              child: const Text('Create Account', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}