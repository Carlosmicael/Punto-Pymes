import 'package:flutter/material.dart';
import 'drawer.dart';
import 'footer.dart';

class HomeLayout extends StatelessWidget {
  final Widget child;

  const HomeLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto Pymes'),
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: true,
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: child),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
