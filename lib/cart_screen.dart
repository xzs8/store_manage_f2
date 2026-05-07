import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(child: Center(child: Text("قائمة المنتجات المضافة"))),
        ElevatedButton(
          onPressed: () {
            // Logic: إنشاء مستند جديد في كولكشن orders
            // الحالة الافتراضية للطلب: "Pending"
          },
          child: const Text("تأكيد الطلب الآن"),
        ),
      ],
    );
  }
}
