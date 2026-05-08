import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const Color primaryOrange = Color(0xFFF57C00);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("تتبع طلباتي"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // جلب طلبات المستخدم الحالي فقط وترتيبها بالأحدث
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryOrange));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("لم تقم بأي طلبات بعد", style: TextStyle(color: Colors.white54)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index];
              var data = order.data() as Map<String, dynamic>;

              // تحديد لون الأيقونة والحالة
              Color statusColor;
              IconData statusIcon;
              String statusText = data['status'] ?? 'قيد المعالجة';

              switch (statusText) {
                case 'تم التوصيل':
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  break;
                case 'في الطريق':
                  statusColor = Colors.blue;
                  statusIcon = Icons.local_shipping;
                  break;
                case 'ملغي':
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  break;
                default:
                  statusColor = primaryOrange;
                  statusIcon = Icons.access_time_filled;
              }

              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("طلب #${order.id.substring(0, 8)}", // عرض جزء من الرقم التسلسلي
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                Icon(statusIcon, color: statusColor, size: 16),
                                const SizedBox(width: 5),
                                Text(statusText, style: TextStyle(color: statusColor, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("إجمالي المبلغ:", style: TextStyle(color: Colors.white70)),
                          Text("${data['totalPrice']} SAR",
                              style: const TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}