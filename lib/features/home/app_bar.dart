import 'package:flutter/material.dart';
import 'package:auth_company/features/user/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomHomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  // 1. Agregamos el callback
  final VoidCallback? onMenuPressed;

  const CustomHomeAppBar({super.key, this.onMenuPressed});

  @override
  Size get preferredSize => const Size.fromHeight(75.0);

  @override
  State<CustomHomeAppBar> createState() => _CustomHomeAppBarState();
}

class _CustomHomeAppBarState extends State<CustomHomeAppBar> {
  final UserService _userService = UserService();
  String _avatarUrl = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('user_uid') ?? '';
    final token = prefs.getString('access_token') ?? '';

    if (uid.isNotEmpty && token.isNotEmpty) {
      final userData = await _userService.getProfile(uid, token);
      if (userData != null) {
        setState(() {
          _avatarUrl = userData['avatar'] ?? '';
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

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
                        onPressed:
                            widget.onMenuPressed ??
                            () =>
                                Scaffold.of(
                                  context,
                                ).openDrawer(), // 3. Usar el callback
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
                              image: _isLoading 
                                  ? const AssetImage('assets/images/perfil.png') as ImageProvider
                                  : (_avatarUrl.isNotEmpty 
                                      ? NetworkImage(_avatarUrl)
                                      : const AssetImage('assets/images/perfil.png') as ImageProvider),
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
