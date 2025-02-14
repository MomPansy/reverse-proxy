import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Components/auth_form_field.dart';
import '../Components/visibility_icon.dart';
import '../Constants/styles.dart';
import '../Services/auth.dart';
import '../Utils/show_snackbar.dart';
import '../Utils/validations.dart';

class SignInForm extends StatefulWidget {
  final bool isLoading;
  final Function setIsLoading;

  const SignInForm({
    super.key,
    required this.setIsLoading,
    required this.isLoading,
  });

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    if (widget.isLoading) return;
    widget.setIsLoading(true);
    if (_formKey.currentState!.validate()) {
      await Login(
        context: context,
        email: _emailController.text,
        password: _passwordController.text,
      ).then((value) => {if (mounted) widget.setIsLoading(false)});
    }
    widget.setIsLoading(false);
  }

  Future<void> _resendVerificationEmail() async {
    if (widget.isLoading) return;
    widget.setIsLoading(true);
    if (_formKey.currentState!.validate()) {
      await Login(
        context: context,
        email: _emailController.text,
        password: _passwordController.text,
      );
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      await SignOut();
    }
    if (mounted) widget.setIsLoading(false);
  }

  Future<void> _sendResetPasswordEmail() async {
    if (_emailController.text.trim() == '') {
      showSnackBar(context, 'Enter a valid email');
    }
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: _emailController.text.trim())
        .then((_) {
      showSnackBar(context, 'Reset password');
    }).onError((e, s) {
      if (e.toString() ==
          '[firebase_auth/invalid-email] The email address is badly formatted.') {
        showSnackBar(context, 'Email not found');
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AuthFormField(
              label: 'Enter email',
              obscureText: false,
              controller: _emailController,
              validator: EmailValidator,
            ),
            const SizedBox(
              height: 24,
            ),
            AuthFormField(
              label: 'Enter password',
              suffixIcon: IconButton(
                icon: VisibilityIcon(isVisible: _isPasswordVisible),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              obscureText: !_isPasswordVisible,
              controller: _passwordController,
              validator: PasswordValidator,
            ),
            const SizedBox(
              height: 28,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                textStyle: TextStyles.FONT_20_BOLD,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                await _login();
              },
              child: const Text('Sign in'),
            ),
            TextButton(
              onPressed: () {
                _sendResetPasswordEmail();
              },
              child: Text(
                'Forgot password',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                _resendVerificationEmail();
              },
              child: Text(
                'Resend email verification',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
