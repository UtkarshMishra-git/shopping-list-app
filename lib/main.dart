import 'package:flutter/material.dart';
import 'package:shopping_list/widgets/grocery_list.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  App({super.key});

  Widget build(BuildContext build) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: GroceryList(),
    );
  }
}
