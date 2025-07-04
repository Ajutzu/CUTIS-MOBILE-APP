import 'package:flutter/material.dart';
import '../theme/app_styles.dart';
import '../widgets/password_field.dart';
import '../../routes/user_service.dart';
import '../widgets/response_dialog.dart';
import '../../routes/user_state.dart';
import '../../routes/session_service.dart';
import '../screens/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final SessionService _sessionService = SessionService();
  bool _loading = true;
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final session = await _sessionService.getSession();
    final user = session.user;
    if (user != null) {
      _nameController.text = user['name'] ?? '';
      _emailController.text = user['email'] ?? '';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final res = await _userService.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      currentPassword: _currentPasswordController.text.isNotEmpty
          ? _currentPasswordController.text
          : null,
      newPassword: _newPasswordController.text.isNotEmpty
          ? _newPasswordController.text
          : null,
    );
    if (mounted) {
      setState(() => _saving = false);
      final bool success = res['success'] == true;
      showResponseDialog(
        context: context,
        isSuccess: success,
        title: success ? 'Success' : 'Error',
        message: res['message'] ?? '',
      );
      if (success) {
        final session = await _sessionService.refreshSession();
        if (!session.isAuthenticated && mounted) {
        } else {
          // update global user name/email
          UserState.name.value = session.user?['name'] ?? UserState.name.value;
          UserState.email.value =
              session.user?['email'] ?? UserState.email.value;
        }
        if (!session.isAuthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthLoginScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile', style: AppTextStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 48),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PasswordField(
                controller: _currentPasswordController,
                labelText: 'Current Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              PasswordField(
                controller: _newPasswordController,
                labelText: 'New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.person, size: 50, color: AppColors.secondary),
        ),
        const SizedBox(height: 16),
        Text(
          'Profile picture not available for privacy reasons',
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle,
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _saving ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Save Changes', style: AppTextStyles.button),
          ),
        ),
      ],
    );
  }
}
