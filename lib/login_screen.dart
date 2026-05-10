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

  Future<void> _signInWithGoogle() async {
    try {
      _showLoading();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) Navigator.pop(context);

      if (userCredential.additionalUserInfo!.isNewUser) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': userCredential.user!.displayName ?? "مستخدم جوجل",
          'email': userCredential.user!.email,
          'role': 'user',
          'createdAt': DateTime.now(),
        });
      }

    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showError("عذراً، حدث خطأ أثناء الاتصال بجوجل: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryOrange = Color(0xFFF57C00);
    final Color backgroundBlack = Color(0xFF121212);
    final Color surfaceGrey = Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: backgroundBlack,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: surfaceGrey, shape: BoxShape.circle),
                child: Text("SH", style: TextStyle(color: primaryOrange, fontSize: 40)),
              ),
              SizedBox(height: 30),

              Text("متجر الشهاب", style: TextStyle(color: primaryOrange, fontSize: 26, fontWeight: FontWeight.bold)),

              SizedBox(height: 50),

              TextField(
                controller: _emailController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: surfaceGrey,
                  hintText: "البريد الإلكتروني",
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.white60),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: surfaceGrey,
                  hintText: "كلمة المرور",
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.white60),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _handleLogin,
                  child: Text("دخول", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              SizedBox(height: 25),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.white10)),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("أو", style: TextStyle(color: Colors.white30))),
                  Expanded(child: Divider(color: Colors.white10)),
                ],
              ),

              SizedBox(height: 25),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  fixedSize: Size(double.maxFinite, 55),
                  side: BorderSide(color: Colors.white12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(Icons.account_circle_outlined, color: Colors.white, size: 30),
                label: Text("إنشاء حساب", style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
              ),

              SizedBox(height: 25),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  fixedSize: Size(double.maxFinite, 55),
                  side: BorderSide(color: Colors.white12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 30),
                label: Text("المتابعة باستخدام جوجل", style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: _signInWithGoogle, // تم الربط
              ),
            ],
          ),
        ),
      ),
    );
  }
}