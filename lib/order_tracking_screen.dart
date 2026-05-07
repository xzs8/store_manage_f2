import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderTrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: 'CURRENT_USER_ID').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text("لا توجد طلبات");
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var order = snapshot.data!.docs[index];
            return Card(
              child: ListTile(
                title: Text("طلب رقم: ${order.id}"),
                subtitle: Text("حالة الطلب: ${order['status']}"), // Status يغيره صاحب العمل
                trailing: const Icon(Icons.info),
              ),
            );
          },
        );
      },
    );
  }
}