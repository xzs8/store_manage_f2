import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const Color primaryOrange = Color(0xFFF57C00);

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // خلفية داكنة متناسقة مع الهوم
      appBar: AppBar(
        title: const Text("سلة المشتريات", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // التأكد من قراءة السلة الخاصة بهذا المستخدم فقط
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('cart')
            .orderBy('addedAt', descending: true) // ترتيب الأحدث أولاً
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryOrange));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.white24),
                  SizedBox(height: 15),
                  Text("سلتك فارغة حالياً", style: TextStyle(color: Colors.white54, fontSize: 18)),
                ],
              ),
            );
          }

          final cartItems = snapshot.data!.docs;

          // حساب الإجمالي مع الحماية من الأخطاء البرمجية للأنواع (String/Double)
          double total = 0;
          for (var item in cartItems) {
            var data = item.data() as Map<String, dynamic>;
            var price = data['price'];
            if (price is String) {
              total += double.tryParse(price) ?? 0;
            } else if (price is num) {
              total += price.toDouble();
            }
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index];
                    var data = item.data() as Map<String, dynamic>;

                    return Card(
                      color: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: (data.containsKey('imageUrl') && data['imageUrl'] != null)
                              ? Image.network(data['imageUrl'], width: 55, height: 55, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey))
                              : const Icon(Icons.shopping_bag, color: primaryOrange),
                        ),
                        title: Text(data['name'] ?? 'منتج',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text("${data['price']} SAR",
                            style: const TextStyle(color: primaryOrange, fontWeight: FontWeight.w500)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => item.reference.delete(), // حذف المنتج من السلة
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ملخص السعر وزر إتمام الشراء
              Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("الإجمالي المستحق", style: TextStyle(color: Colors.white70, fontSize: 16)),
                        Text("${total.toStringAsFixed(2)} SAR",
                            style: const TextStyle(color: primaryOrange, fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () => _checkout(context, cartItems, total),
                        child: const Text("إرسال الطلب", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // دالة إتمام الطلب ونقله إلى كولكشن الطلبات
  Future<void> _checkout(BuildContext context, List<QueryDocumentSnapshot> items, double total) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // جلب بيانات العميل الحقيقية من كولكشن users
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // التحقق من وجود البيانات لتجنب "عميل غير مسجل"
      if (!userDoc.exists ||
          userDoc['fullName'] == null || userDoc['fullName'].toString().isEmpty ||
          userDoc['phone'] == null || userDoc['phone'].toString().isEmpty) {

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("يرجى إكمال بياناتك في البروفايل أولاً (الاسم ورقم الهاتف)")),
          );
        }
        return;
      }

      // إرسال الطلب مع كافة التفاصيل لصاحب المتجر
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'userName': userDoc['fullName'], // الاسم الحقيقي من البروفايل
        'userPhone': userDoc['phone'],   // رقم الهاتف للتواصل
        'userAddress': userDoc['address'] ?? 'لم يحدد عنوان',
        'userEmail': user.email,
        'totalPrice': total,
        'status': 'قيد الانتظار',
        'createdAt': FieldValue.serverTimestamp(),
        'items': items.map((i) => i.data()).toList(),
      });

      // مسح السلة
      for (var item in items) {
        await item.reference.delete();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إرسال طلبك بنجاح!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ أثناء الطلب: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}