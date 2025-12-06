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
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: height * 0.01,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: width * 0.09,
                      height: width * 0.09,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: width * 0.10,
                          height: width * 0.10,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),

                        SizedBox(width: width * 0.04),
                        Container(
                          width: width * 0.12,
                          height: width * 0.12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://ichef.bbci.co.uk/ace/ws/640/cpsprodpb/9db5/live/48fd9010-c1c1-11ee-9519-97453607d43e.jpg.webp',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
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
