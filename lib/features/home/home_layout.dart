import 'package:flutter/material.dart';
import 'drawer.dart';
import 'footer.dart';
import 'app_bar.dart';

class HomeLayout extends StatelessWidget {
  final Widget child;

  const HomeLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomHomeAppBar(),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          child,
          const Positioned(left: 0,right: 0,bottom: 0,child: FloatingFooter(),),
        ],
      ),
    );
  }
}





















