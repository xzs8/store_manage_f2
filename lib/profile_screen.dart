import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: "الاسم الكامل")),
          TextField(controller: addressController, decoration: const InputDecoration(labelText: "عنوان التوصيل")),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // حفظ البيانات في Firestore تحت كولكشن users
            },
            child: const Text("حفظ البيانات"),
          )
        ],
      ),
    );
  }
}