import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w300),),
      ),
      body: const Column(
        children: [
          Text("This is your homepage!"),
        ],
      ),
    );
  }
}