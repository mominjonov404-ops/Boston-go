import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';

const ink = Color(0xFF171717);
const cream = Color(0xFFF6F2EA);
const gold = Color(0xFFC49A58);
const muted = Color(0xFF77736C);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var configured = false;
  try {
    if (AppConfig.supabaseUrl.startsWith('https://') &&
        !AppConfig.supabaseUrl.contains('YOUR_PROJECT_REF') &&
        !AppConfig.supabaseAnonKey.contains('YOUR_SUPABASE')) {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      configured = true;
    }
  } catch (_) {}
  runApp(BostonGoApp(supabaseConfigured: configured));
}

class BostonGoApp extends StatelessWidget {
  const BostonGoApp({super.key, required this.supabaseConfigured});
  final bool supabaseConfigured;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bo'ston Go",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(seedColor: gold, brightness: Brightness.light),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(backgroundColor: cream, foregroundColor: ink, elevation: 0),
      ),
      home: supabaseConfigured ? const AuthGate() : const SetupScreen(),
    );
  }
}

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const BrandMark(),
        const SizedBox(height: 22),
        const Text('Bo‘ston Go', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: ink)),
        const SizedBox(height: 10),
        const Text('Ilovani ishga tushirish uchun Supabase sozlamalarini kiriting.',
          textAlign: TextAlign.center, style: TextStyle(color: muted)),
        const SizedBox(height: 16),
        const Text('1. lib/config.example.dart faylidan config.dart nusxa oling.\n2. Supabase URL va publishable/anon key ni kiriting.\n3. Ilovani qayta ishga tushiring.',
          style: TextStyle(height: 1.6), textAlign: TextAlign.left),
      ]),
    )),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        return session == null ? const AuthScreen() : const MainShell();
      },
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 64, height: 64,
    decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(20)),
    child: const Icon(Icons.near_me_rounded, color: gold, size: 34),
  );
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool signup = false, busy = false;
  String? error;

  Future<void> submit() async {
    setState(() { busy = true; error = null; });
    try {
      final auth = Supabase.instance.client.auth;
      if (signup) {
        await auth.signUp(email: email.text.trim(), password: password.text);
      } else {
        await auth.signInWithPassword(email: email.text.trim(), password: password.text);
      }
    } on AuthException catch (e) {
      setState(() => error = e.message);
    } catch (_) {
      setState(() => error = 'Ulanishda xatolik. Sozlamalarni tekshiring.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Center(child: BrandMark()),
        const SizedBox(height: 20),
        const Text('Bo‘ston Go', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: ink)),
        const SizedBox(height: 6),
        const Text('Shahringizdagi xizmatlar — bir joyda', textAlign: TextAlign.center,
          style: TextStyle(color: muted)),
        const SizedBox(height: 32),
        Text(signup ? 'Hisob yaratish' : 'Xush kelibsiz',
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(controller: email, keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
        const SizedBox(height: 12),
        TextField(controller: password, obscureText: true,
          decoration: const InputDecoration(labelText: 'Parol', prefixIcon: Icon(Icons.lock_outline))),
        if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
          child: Text(error!, style: const TextStyle(color: Colors.red))),
        const SizedBox(height: 20),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: ink, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: busy ? null : submit,
          child: Text(busy ? 'Kuting...' : signup ? 'Ro‘yxatdan o‘tish' : 'Kirish')),
        TextButton(onPressed: () => setState(() { signup = !signup; error = null; }),
          child: Text(signup ? 'Hisobingiz bormi? Kirish' : 'Hisob yaratish')),
      ]),
    ))),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int index = 0;
  final pages = const [HomeScreen(), OrdersScreen(), ProfileScreen()];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: pages[index],
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (v) => setState(() => index = v),
      backgroundColor: Colors.white,
      indicatorColor: gold.withOpacity(.18),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Bosh sahifa'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Buyurtmalar'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
      ],
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const categories = [
    (Icons.restaurant_outlined, 'Taomlar'),
    (Icons.shopping_bag_outlined, 'Do‘konlar'),
    (Icons.local_taxi_outlined, 'Taksi'),
    (Icons.delivery_dining_outlined, 'Yetkazish'),
  ];
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Row(children: [
        const BrandMark(),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bo‘ston Go', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)),
          Text('Bo‘ston xizmatlari bir joyda', style: TextStyle(color: muted, fontSize: 12)),
        ])),
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
      ]),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(24)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Vaqtingizni tejang.', style: TextStyle(color: gold, fontSize: 13, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('Kerakli xizmatlar\\nendi bir ilovada.', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold, height: 1.2)),
          SizedBox(height: 8),
          Text('Bo‘ston uchun qulay xizmatlar platformasi', style: TextStyle(color: Colors.white70)),
        ]),
      ),
      const SizedBox(height: 26),
      const Text('Xizmatlar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ink)),
      const SizedBox(height: 14),
      GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.55),
        itemBuilder: (context, i) => Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(categories[i].$1, size: 30, color: gold),
            const SizedBox(height: 8),
            Text(categories[i].$2, style: const TextStyle(fontWeight: FontWeight.w700, color: ink)),
          ]),
        ),
      ),
      const SizedBox(height: 22),
      const Text('Yaqinda', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ink)),
      const SizedBox(height: 8),
      const Text('Hamkorlar va xizmatlar qo‘shilishi bilan ular shu yerda ko‘rinadi.',
        style: TextStyle(color: muted, height: 1.5)),
    ],
  ));
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) => const SafeArea(child: Center(child: Padding(
    padding: EdgeInsets.all(28),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.receipt_long_outlined, size: 54, color: gold),
      SizedBox(height: 14),
      Text('Buyurtmalar', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: ink)),
      SizedBox(height: 8),
      Text('Hozircha buyurtmalar yo‘q.', style: TextStyle(color: muted)),
    ]),
  )));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return SafeArea(child: Padding(padding: const EdgeInsets.all(22), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Profil', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: ink)),
        const SizedBox(height: 22),
        Container(width: double.infinity, padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            const CircleAvatar(backgroundColor: cream, child: Icon(Icons.person, color: ink)),
            const SizedBox(width: 12),
            Expanded(child: Text(user?.email ?? 'Foydalanuvchi', style: const TextStyle(fontWeight: FontWeight.w600))),
          ])),
        const Spacer(),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(
          onPressed: () async => Supabase.instance.client.auth.signOut(),
          icon: const Icon(Icons.logout), label: const Text('Chiqish'))),
      ],
    )));
  }
}
