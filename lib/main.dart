import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/category_screen.dart';
import 'viewmodels/product_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyrikApp());
}

class MyrikApp extends StatelessWidget {
  const MyrikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Myrik',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
          ),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const CategoryScreen(),
      ),
    );
  }
}
