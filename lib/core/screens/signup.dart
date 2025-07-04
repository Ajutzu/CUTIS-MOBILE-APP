import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import '../theme/app_styles.dart';
import '../widgets/password_field.dart';
import '../widgets/response_dialog.dart';
import '../../routes/authentication_service.dart';



class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  final AuthenticationService _authService = AuthenticationService();

  void _onSignup() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);

    final AuthResponse response = await _authService.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response.success) {
      Navigator.of(context).pop();
      showResponseDialog(
        context: context,
        isSuccess: true,
        title: 'Success',
        message: response.message.isNotEmpty ? response.message : 'Signup successful',
      );
    } else {
      showResponseDialog(
        context: context,
        title: 'Signup Failed',
        message: response.message.isNotEmpty ? response.message : 'Signup failed. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Create an account',
                  style: AppTextStyles.heading,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your details brelow to create your account',
                  style: AppTextStyles.subtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'm@example.com',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email is required';
                    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _passwordController,
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  validator: (value) {
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _onSignup,
                  child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Create Account', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR CONTINUE WITH', style: TextStyle(fontSize: 12)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                SignInButton(
                  Buttons.Google,
                  onPressed: () {},
                  text: '    Sign up with Google',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
