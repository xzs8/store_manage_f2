import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تحديد الألوان الرئيسية للثيم
    const Color primaryOrange = Color(0xFFF57C00); // برتقالي قوي
    const Color backgroundBlack = Color(0xFF121212); // أسود داكن للخلفية
    const Color surfaceGrey = Color(0xFF1E1E1E); // رمادي داكن جداً للعناصر

    return Scaffold(
      backgroundColor: backgroundBlack,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. رمز نصي بسيط بدلاً من اللوجو المرسوم (A - الشهاب)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: surfaceGrey,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  "A", // حرف يرمز لـ (الشهاب)
                  style: TextStyle(
                    color: primaryOrange,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 2. اسم المتجر (البرتقالي للأهمية)
              const Text(
                "متجر الشهاب",
                style: TextStyle(
                  color: primaryOrange,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "تسجيل الدخول للبدء",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 50),

              // 3. حقل الإيميل (تبسيط الإطار)
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: surfaceGrey,
                  hintText: "البريد الإلكتروني",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.white60),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // حواف أنعم وبدون إطار بارز
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. حقل كلمة المرور
              TextField(
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: surfaceGrey,
                  hintText: "كلمة المرور",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.white60),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 5. زر تسجيل الدخول (برتقالي)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2, // ظل خفيف جداً
                  ),
                  onPressed: () {},
                  child: const Text(
                    "دخول", // تبسيط النص
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // 6. فاصل "أو" (بسيط)
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.white10)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("أو", style: TextStyle(color: Colors.white30)),
                  ),
                  Expanded(child: Divider(color: Colors.white10)),
                ],
              ),
              const SizedBox(height: 25),

              // 7. زر تسجيل دخول قوقل (الأبيض لكسر الحدة)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  fixedSize: const Size(double.maxFinite, 55),
                  side: const BorderSide(color: Colors.white12), // إطار خفيف
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // أيقونة قوقل الرسمية (تأكد من وجودها في الأصول أو استخدام مكتبة)
                icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 30,),
                label: const Text(
                  "المتابعة باستخدام جوجل",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}