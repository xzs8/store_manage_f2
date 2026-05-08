import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      _showMessage("يرجى ملء جميع الحقول");
      return;
    }

    try {
      _showLoading();

      // 1. إنشاء الحساب في Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. حفظ البيانات الإضافية في Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'user',
        'createdAt': DateTime.now(),
      });

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // إغلاق الدائرة
        Navigator.pop(context); // العودة للوجن أو الرئيسية
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _showMessage("حدث خطأ: ${e.toString()}");
    }
  }

  void _showLoading() {
    showDialog(context: context, barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFF57C00))));
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFFF57C00)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("إنشاء حساب جديد", style: TextStyle(color: Color(0xFFF57C00), fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            _buildField(_nameController, "الاسم الكامل", Icons.person_outline),
            const SizedBox(height: 16),
            _buildField(_emailController, "البريد الإلكتروني", Icons.email_outlined),
            const SizedBox(height: 16),
            _buildField(_passwordController, "كلمة المرور", Icons.lock_outline, isPass: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF57C00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _signUp,
                child: const Text("تأكيد التسجيل", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, {bool isPass = false}) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true, fillColor: const Color(0xFF1E1E1E),
        hintText: hint, hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white60),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}