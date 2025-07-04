import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final InputBorder? border;
  final FormFieldValidator<String>? validator;
  const PasswordField({Key? key, this.controller, this.labelText, this.hintText, this.border, this.validator}) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText ?? 'Password',
        hintText: widget.hintText ?? '',
        border: widget.border ?? const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: _toggleVisibility,
        ),
      ),
    );
  }
}
