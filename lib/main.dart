import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'order_tracking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'متجر الشهاب',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // نفس خلفية اللوجن
        primaryColor: const Color(0xFFF57C00), // البرتقالي حق الشهاب
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF57C00),
          brightness: Brightness.dark,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            // بدلاً من HomeScreen مباشرة، نفتح الـ RootPage التي تحتوي على الـ NavBar
            return const RootPage();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

// هذه هي الصفحة الأساسية التي ستتحكم في التنقل بين الصفحات الخمس للعميل
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {

  int _currentIndex = 0;

  // قائمة الصفحات (تأكد من إنشاء هذه الكلاسات في ملفاتها)
  final List<Widget> _pages = [
    HomeScreen(),
    CartScreen(),
    OrderTrackingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'السلة'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'طلباتي'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}