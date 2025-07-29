import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import '../theme/app_styles.dart';
import '../widgets/password_field.dart';
import '../widgets/response_dialog.dart';
import '../../routes/authentication_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _termsAccepted = false;

  final AuthenticationService _authService = AuthenticationService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '170384538510-8upkkoio508msp6b3mcpk0jcuif52b83.apps.googleusercontent.com',
  );

  void _onSignup() async {
    if (_formKey.currentState?.validate() != true) return;

    if (!_termsAccepted) {
      showResponseDialog(
        context: context,
        title: 'Terms Required',
        message: 'You must read and accept the terms and conditions to continue',
      );
      return;
    }

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
        message: response.message.isNotEmpty
            ? response.message
            : 'Signup successful',
      );
    } else {
      showResponseDialog(
        context: context,
        title: 'Signup Failed',
        message: response.message.isNotEmpty
            ? response.message
            : 'Signup failed. Please try again.',
      );
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms and Conditions', style: AppTextStyles.heading),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'By using Cutis, you agree to the following:',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 16),
              Text(
                '1. Cutis will have access to your camera and images for:\n'
                '- Future model training\n'
                '- Image processing\n'
                '- Finding clinics and dermatologists based on location\n'
                '\n'
                '2. The only required personal information is your email address. Username is optional.\n'
                '\n'
                '3. Your password is securely encrypted and stored.\n'
                '\n'
                '4. All image data will be processed securely and used only for diagnostic purposes.\n'
                '\n'
                '5. You can request deletion of your data at any time through the app settings.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _onGoogleSignup() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;
      if (idToken == null) {
        setState(() => _isLoading = false);
        showResponseDialog(
          context: context,
          message: 'Failed to retrieve Google token',
        );
        return;
      }

      final AuthResponse response = await _authService.googleLogin(idToken);
      if (response.success) {
        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(userName: response.user?['name'] ?? ''),
          ),
        );
      } else {
        showResponseDialog(
          context: context,
          title: 'Google Sign-Up Failed',
          message: response.message,
        );
      }
    } catch (e) {
      showResponseDialog(
        context: context,
        title: 'Error',
        message: 'Google sign-in failed: $e',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                Image.asset('assets/images/Cutis.png', height: 100),
                const SizedBox(height: 8),
                Text('Create an account', style: AppTextStyles.heading),
                const SizedBox(height: 8),
                Text(
                  'Enter your details below to create your account',
                  style: AppTextStyles.subtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'm@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Email is required';
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegex.hasMatch(value))
                      return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _passwordController,
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Password is required';
                    if (value.length < 8)
                      return 'Password must be at least 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text)
                      return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (value) => setState(() => _termsAccepted = value ?? false),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                WidgetSpan(
                                  child: InkWell(
                                    onTap: _showTermsDialog,
                                    child: Text(
                                      'Terms and Conditions',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!_termsAccepted)
                            Text(
                              'You must accept the terms to continue',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
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
                      child: Text(
                        'OR CONTINUE WITH',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                SignInButton(
                  Buttons.Google,
                  onPressed: () {
                    if (!_isLoading) {
                      _onGoogleSignup();
                    }
                  },
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
