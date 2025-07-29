import 'package:flutter/material.dart';
import '../theme/app_styles.dart';
import '../screens/login.dart';
import '../../routes/user_state.dart';
import '../../routes/token_service.dart';

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

  Future<void> _logout(BuildContext context) async {
    try {
      await TokenService().logout();
    } catch (_) {
      // Ignore logout errors and still proceed to clear local session
    }
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
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 16,
            title: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 18,
                    child: Text(
                      _initials(displayName),
                      style: AppTextStyles.button.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayName,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.logout_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  tooltip: 'Logout',
                  onPressed: () => _logout(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}