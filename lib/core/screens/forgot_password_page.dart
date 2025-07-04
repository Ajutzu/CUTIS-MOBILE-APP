import 'package:flutter/material.dart';
import '../theme/app_styles.dart';
import '../widgets/response_dialog.dart';
import '../../routes/authentication_service.dart';
import '../widgets/password_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

enum ForgotPasswordState { enterEmail, enterOtp, resetPassword }

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final PageController _pageController = PageController();
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyOtp = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthenticationService _authService = AuthenticationService();
  bool _isLoading = false;
  String _otp = '';

  String _userEmail = '';

  Future<void> _submitEmail() async {
    if (_formKeyEmail.currentState?.validate() != true) return;
    setState(() => _isLoading = true);
    final res = await _authService.forgotPassword(_emailController.text.trim());
    setState(() => _isLoading = false);
    if (res['success'] == true || (res['message'] ?? '').toString().toLowerCase().contains('sent')) {
      setState(() {
        _userEmail = _emailController.text.trim();
      });
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      showResponseDialog(context: context, isSuccess: true, title: 'Email Sent', message: res['message'] ?? 'OTP sent to your email');
    } else {
      showResponseDialog(context: context, title: 'Error', message: res['message'] ?? 'Failed to send email');
    }
  }

  Future<void> _submitOtp() async {
    if (_formKeyOtp.currentState?.validate() == true) {
      setState(() => _isLoading = true);
      final res = await _authService.verifyOtp(_otp);
      setState(() => _isLoading = false);
      if (res['success'] == true) {
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      } else {
        showResponseDialog(context: context, title: 'Error', message: res['message'] ?? 'Invalid OTP');
      }
    }
  }

  Future<void> _submitNewPassword() async {
    if (_formKeyPassword.currentState?.validate() == true) {
      setState(() => _isLoading = true);
      final res = await _authService.updatePassword(_passwordController.text);
      setState(() => _isLoading = false);
      if (res['success'] == true) {
        Navigator.of(context).pop();
        showResponseDialog(context: context, isSuccess: true, title: 'Success', message: res['message'] ?? 'Password reset successfully');
      } else {
        showResponseDialog(context: context, title: 'Error', message: res['message'] ?? 'Failed to reset password');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildEnterEmailView(),
          _buildEnterOtpView(),
          _buildResetPasswordView(),
        ],
      ),
    );
  }

  Widget _buildEnterEmailView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Form(
        key: _formKeyEmail,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Reset Password', style: AppTextStyles.heading),
            const SizedBox(height: 8),
            const Text('Enter the email associated with your account and we\'ll send an email with instructions to reset your password.', style: AppTextStyles.subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email is required';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitEmail,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading ? const SizedBox(height:20,width:20,child:CircularProgressIndicator(color: Colors.white, strokeWidth:2)) : const Text('Send Instructions', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnterOtpView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Form(
        key: _formKeyOtp,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter OTP', style: AppTextStyles.heading),
            const SizedBox(height: 8),
            Text('An OTP has been sent to $_userEmail', style: AppTextStyles.subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => _buildOtpBox(index)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitOtp,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading ? const SizedBox(height:20,width:20,child:CircularProgressIndicator(color: Colors.white, strokeWidth:2)) : const Text('Verify', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TextFormField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: '',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (_otp.length > index) {
              _otp = _otp.replaceRange(index, index + 1, value);
            } else {
              _otp += value;
            }
          } else {
            if (_otp.isNotEmpty && index < _otp.length) {
              _otp = _otp.replaceRange(index, index + 1, '');
            }
          }
          if (value.length == 1 && index < 3) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  Widget _buildResetPasswordView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Form(
        key: _formKeyPassword,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Create New Password', style: AppTextStyles.heading),
            const SizedBox(height: 8),
            const Text('Your new password must be different from previously used passwords.', style: AppTextStyles.subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            PasswordField(
              controller: _passwordController,
              labelText: 'New Password',
              border: const OutlineInputBorder(),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password is required';
                if (value.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
            PasswordField(
              labelText: 'Confirm New Password',
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
                onPressed: _isLoading ? null : _submitNewPassword,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading ? const SizedBox(height:20,width:20,child:CircularProgressIndicator(color: Colors.white, strokeWidth:2)) : const Text('Reset Password', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
