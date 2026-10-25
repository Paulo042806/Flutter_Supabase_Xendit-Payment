
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/product_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wmnyvemqrlfiwshssjcc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indtbnl2ZW1xcmxmaXdzaHNzamNjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI0MjQ5MTgsImV4cCI6MjEwODAwMDkxOH0.jqnLy6DMft34BakfKWJL1wrF7erWmKut1rpaZQfZc_8',
  );

  runApp(const StudentEcommerceApp());
}

class StudentEcommerceApp extends StatelessWidget {
  const StudentEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Shop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const ProductListScreen(),
    );
  }
}
