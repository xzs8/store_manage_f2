import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsScreen extends StatelessWidget {
  final DocumentSnapshot product;
  const ProductDetailsScreen({super.key, required this.product});

  // دالة الإضافة إلى السلة (متوافقة مع تعديلات الهوم سكرين)
  Future<void> _addToCart(BuildContext context, Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    const Color primaryOrange = Color(0xFFF57C00);

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .add({
          'name': data['name'] ?? 'منتج بدون اسم',
          'price': data['price'] ?? '0',
          // الحماية هنا: نتحقق من imageUrl أولاً ثم image كما فعلنا في الهوم
          'imageUrl': data['imageUrl'] ?? data['image'] ?? '',
          'addedAt': FieldValue.serverTimestamp(),
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("تمت إضافة ${data['name']} إلى السلة"),
              backgroundColor: primaryOrange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("حدث خطأ: $e"), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى تسجيل الدخول أولاً"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = product.data() as Map<String, dynamic>;
    // توافق مع مسميات الحقول المختلفة في قاعدة البيانات
    String? imageUrl = data['imageUrl'] ?? data['image'];
    const Color primaryOrange = Color(0xFFF57C00);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(data['name'] ?? 'التفاصيل', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عرض الصورة مع معالجة الخطأ
            (imageUrl != null && imageUrl.isNotEmpty)
                ? Image.network(
              imageUrl,
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 350,
                color: Colors.grey[900],
                child: const Icon(Icons.broken_image, size: 100, color: Colors.white24),
              ),
            )
                : Container(
              height: 350,
              color: Colors.grey[900],
              child: const Icon(Icons.image, size: 100, color: Colors.white24),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data['name'] ?? 'بدون اسم',
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "${data['price']} SAR", // تغيير العملة لـ SAR لتتوافق مع الهوم
                        style: const TextStyle(color: primaryOrange, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "الوصف:",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data['description'] ?? 'لا يوجد وصف حالياً لهذا المنتج في متجر الشهاب.',
                    style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // تمييز بسيط لمنطقة الزر
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ElevatedButton.icon(
          onPressed: () => _addToCart(context, data),
          icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
          label: const Text("إضافة إلى السلة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryOrange,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }
}