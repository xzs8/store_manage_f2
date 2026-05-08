import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  // دالة حفظ البيانات
  Future<void> _updateProfile() async {
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'fullName': nameController.text,
        'address': addressController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تحديث البيانات بنجاح")),
      );
    }
  }

  // دالة تسجيل الخروج
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // الـ StreamBuilder في الـ MyApp سيتكفل بنقلك لصفحة اللوجن تلقائياً
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الملف الشخصي"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.person_pin, size: 100, color: Color(0xFFF57C00)),
              Text(user?.email ?? "لا يوجد إيميل", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "الاسم الكامل", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "عنوان التوصيل", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 30),

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF57C00)),
                  onPressed: _updateProfile,
                  child: const Text("حفظ البيانات", style: TextStyle(color: Colors.white)),
                ),
              ),

              const SizedBox(height: 10),

              // زر تسجيل الخروج
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text("تسجيل الخروج", style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}