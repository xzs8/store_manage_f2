import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:store_manage_f2/Create_account.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // دالة الدخول العادي
  Future<void> _handleLogin() async {
    try {
      _showLoading();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);
      _showError(e.message ?? "حدث خطأ ما");
    }
  }


  // دالة جوجل المعدلة (بدون تعقيد)
  Future<void> _signInWithGoogle() async {
    try {
      _showLoading(); // الدائرة اللي سويناها قبل شوي

      // 1. بدء تشغيل واجهة اختيار الحساب من جوجل
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        if (mounted) Navigator.pop(context);
        return; // المستخدم كنسل العملية
      }

      // 2. الحصول على توقيع الدخول (Authentication)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. إنشاء مفتاح الدخول لفايربيس
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. تسجيل الدخول في فايربيس باستخدام المفتاح
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // 5. حفظ بياناته في Firestore إذا كان أول مرة يسجل (مهم جداً للرول)
      if (userCredential.additionalUserInfo!.isNewUser) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': userCredential.user!.displayName ?? "مستخدم جوجل",
          'email': userCredential.user!.email,
          'role': 'user',
          'createdAt': DateTime.now(),
        });
      }

      if (mounted) Navigator.pop(context); // إغلاق الدائرة بعد النجاح

    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showError("عذراً، حدث خطأ أثناء الاتصال بجوجل: $e");
    }
  }

  // دوال مساعدة لتقليل تكرار الكود
  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFF57C00))),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFF57C00)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFF57C00);
    const Color backgroundBlack = Color(0xFF121212);
    const Color surfaceGrey = Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: backgroundBlack,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: surfaceGrey, shape: BoxShape.circle),
                child: const Text("A", style: TextStyle(color: primaryOrange, fontSize: 48, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),
              const Text("متجر الشهاب", style: TextStyle(color: primaryOrange, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 50),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: surfaceGrey,
                  hintText: "البريد الإلكتروني",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.white60),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: surfaceGrey,
                  hintText: "كلمة المرور",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.white60),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _handleLogin,
                  child: const Text("دخول", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 25),
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.white10)),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("أو", style: TextStyle(color: Colors.white30))),
                  Expanded(child: Divider(color: Colors.white10)),
                ],
              ),
              const SizedBox(height: 25),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  fixedSize: const Size(double.maxFinite, 55),
                  side: const BorderSide(color: Colors.white12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 30),
                label: const Text("إنشاء حساب", style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                },
              ),
              const SizedBox(height: 25),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  fixedSize: const Size(double.maxFinite, 55),
                  side: const BorderSide(color: Colors.white12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 30),
                label: const Text("المتابعة باستخدام جوجل", style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: _signInWithGoogle, // تم الربط
              ),
            ],
          ),
        ),
      ),
    );
  }
}