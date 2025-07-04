import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showError("Semua field harus diisi.");
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showError("Konfirmasi kata sandi tidak cocok.");
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registrasi berhasil! Silakan login."),
          backgroundColor: Colors.green,
        ),
      );

      await FirebaseAuth.instance.signOut();
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Registrasi gagal.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  InputDecoration buildInputDecoration(String label, IconData icon,
      {bool isPassword = false, VoidCallback? toggleVisibility, bool obscure = true}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      floatingLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      prefixIcon: Icon(icon, color: Colors.black),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: toggleVisibility,
              color: Colors.grey,
            )
          : null,
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 37, 57, 159),
      appBar: AppBar(title: const Text("Daftar Akun")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_add_alt_1, size: 40, color: Colors.blue),
            ),
            const SizedBox(height: 24),
            const Text(
              "Buat akun baru untuk mulai quiz!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: nameController,
              decoration: buildInputDecoration("Nama", Icons.person, isPassword: false),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: buildInputDecoration("Email", Icons.email, isPassword: false),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: buildInputDecoration("Kata Sandi", Icons.lock,
                  isPassword: true,
                  obscure: _obscurePassword,
                  toggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: buildInputDecoration("Konfirmasi Kata Sandi", Icons.lock_outline,
                  isPassword: true,
                  obscure: _obscureConfirmPassword,
                  toggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  }),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Daftar", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Sudah punya akun? Kembali ke Login",
                  style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}
