
import 'package:flutter/material.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomHomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(75.0); 

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    
    final double appBarHeight = height * 0.25; 

    return AppBar(
      toolbarHeight: appBarHeight, 
      automaticallyImplyLeading: false, 
      backgroundColor: const Color.fromARGB(0, 189, 22, 22),
      elevation: 0,
      forceMaterialTransparency: true,
      flexibleSpace: Container(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size:  30),
                      onPressed: () => Scaffold.of(context).openDrawer(), 
                    ),
                    Row(
                      children: [
                        const Icon(Icons.notifications_none, color: Colors.white, size: 30),
                        SizedBox(width: width * 0.04),
                        Container(width: width * 0.10,height: width * 0.10,
                          decoration: const BoxDecoration(color: Colors.white,shape: BoxShape.circle,),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


