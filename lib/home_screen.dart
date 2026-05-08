import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // متغير لحفظ القسم المختار، افتراضياً "الكل"
  String selectedCategory = "الكل";

  Future<void> _addToCart(BuildContext context, Map<String, dynamic> productData) async {
    final user = FirebaseAuth.instance.currentUser;
    const Color primaryOrange = Color(0xFFF57C00);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى تسجيل الدخول أولاً")));
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .add({
        'name': productData['name'],
        'price': productData['price'],
        'imageUrl': productData['imageUrl'] ?? productData['image'] ?? '',
        'addedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تمت إضافة ${productData['name']} للسلة"), backgroundColor: primaryOrange),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: $e"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFF57C00);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Center(child: Text("متجر الشهاب", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
        backgroundColor: primaryOrange,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("الأقسام", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),

            // 1. قسم الأقسام مع تفعيل الضغط
            SizedBox(
              height: 120,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: primaryOrange));
                  var cats = snapshot.data!.docs;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cats.length + 1, // +1 لزر "الكل"
                    itemBuilder: (context, index) {
                      String catName = (index == 0) ? "الكل" : cats[index - 1]['name'];
                      String catImg = (index == 0)
                          ? "https://cdn-icons-png.flaticon.com/512/570/570170.png"
                          : cats[index - 1]['image'];

                      bool isSelected = selectedCategory == catName;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = catName; // تحديث القسم المختار عند الضغط
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 70, height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(15),
                                border: isSelected ? Border.all(color: primaryOrange, width: 2) : null,
                                image: DecorationImage(image: NetworkImage(catImg), fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                                catName,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? primaryOrange : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                )
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("المنتجات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),

            // 2. عرض المنتجات المفلترة بناءً على القسم
            StreamBuilder<QuerySnapshot>(
              stream: selectedCategory == "الكل"
                  ? FirebaseFirestore.instance.collection('products').snapshots()
                  : FirebaseFirestore.instance
                  .collection('products')
                  .where('category', isEqualTo: selectedCategory)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: primaryOrange));
                var products = snapshot.data!.docs;

                if (products.isEmpty) {
                  return const Center(child: Text("لا توجد منتجات في هذا القسم", style: TextStyle(color: Colors.white54)));
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var pDoc = products[index];
                    var p = pDoc.data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: pDoc)));
                      },
                      child: Container(
                        decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  image: DecorationImage(
                                      image: NetworkImage(p['imageUrl'] ?? p['image'] ?? 'https://via.placeholder.com/150'),
                                      fit: BoxFit.cover
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(p['name'] ?? 'منتج', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1),
                                  Text("${p['price']} SAR", style: const TextStyle(color: primaryOrange, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryOrange,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      minimumSize: const Size(double.infinity, 35),
                                    ),
                                    onPressed: () => _addToCart(context, p),
                                    child: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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