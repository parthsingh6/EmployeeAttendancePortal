import 'package:flutter/material.dart';

// Sample home page created during Flutter practice

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Sample data used for Flutter learning

  final int days = 30;
  final String name = "Parth";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Catalog App")),
      body: Center(child: Text("Welcome to $days days of flutter by $name")),
      drawer: Drawer(),
    );
  }
}


  // Builds the sample Home page