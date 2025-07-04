import 'package:flutter/material.dart';
import '../theme/app_styles.dart';
import '../screens/login.dart';
import '../../routes/user_state.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName; // initial fallback

  const CustomAppBar({Key? key, this.userName = ''}) : super(key: key);

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    String init = parts.first[0];
    if (parts.length > 1) init += parts.last[0];
    return init.toUpperCase();
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthLoginScreen()),
      (route) => false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: UserState.name,
      builder: (_, value, __) {
        final displayName = value.isNotEmpty ? value : (userName.isNotEmpty ? userName : 'User');
        return AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  _initials(displayName),
                  style: AppTextStyles.button,
                ),
              ),
              const SizedBox(width: 12),
              Text(displayName, style: AppTextStyles.heading),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.primary),
              tooltip: 'Logout',
              onPressed: () => _logout(context),
            ),
          ],
        );
      },
    );
  }
}
