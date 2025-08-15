import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isSignIn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isSignIn ? 'Sign In' : 'Sign Up',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 30),

              // Sign In fields
              if (isSignIn) ...[
                TextField(
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 15),
                TextField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text('Sign In'),
                ),
              ]

              // Sign Up fields
              else ...[
                TextField(
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 15),
                TextField(
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 15),
                TextField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                TextField(
                  decoration: const InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text('Sign Up'),
                ),
              ],

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  setState(() {
                    isSignIn = !isSignIn;
                  });
                },
                child: Text(
                  isSignIn
                      ? "Don't have an account? Sign Up"
                      : "Already have an account? Sign In",
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
