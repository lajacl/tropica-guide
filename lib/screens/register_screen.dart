import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tropica_guide/auth/validators.dart';
import 'package:tropica_guide/screens/trips_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
            'firstName': firstNameCtrl.text.trim(),
            'lastName': lastNameCtrl.text.trim(),
            'email': emailCtrl.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TripsScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: firstNameCtrl,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: lastNameCtrl,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) =>
                      isValidEmail(v ?? '') ? null : 'Invalid email',
                ),
                TextFormField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => validatePassword(v ?? ''),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: loading ? null : register,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text('Create Account'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
