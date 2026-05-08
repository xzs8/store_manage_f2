import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("متجر الشهاب", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF57C00), // لون الشهاب البرتقالي
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. قسم الأقسام (عرض أفقي)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("الأقسام", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 120,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  var cats = snapshot.data!.docs;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cats.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 70, height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(image: NetworkImage(cats[index]['image']), fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(cats[index]['name'], style: const TextStyle(fontSize: 12)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // 2. عرض المنتجات (Grid)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("أحدث المنتجات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var products = snapshot.data!.docs;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var p = products[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                image: DecorationImage(image: NetworkImage(p['image']), fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                                Text("${p['price']} SAR", style: const TextStyle(color: Color(0xFFF57C00))),
                                const SizedBox(height: 5),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF57C00),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    minimumSize: const Size(double.infinity, 30),
                                  ),
                                  onPressed: () {
                                    // دالة الإضافة للسلة سنبرمجها لاحقاً
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("تمت إضافة ${p['name']} للسلة")),
                                    );
                                  },
                                  child: const Icon(Icons.add_shopping_cart, size: 18, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}