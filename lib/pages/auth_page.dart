// ignore_for_file: file_names

import 'package:askngo/Components/sign_in_form.dart';
import 'package:flutter/material.dart';

import '../Components/auth_page_header.dart';
import '../Components/google_button.dart';
import '../Services/auth.dart';
import '../Utils/show_snackbar.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  static const routeName = '/auth';

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = false;

  void _setIsLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  Future<void> _loginWithGoogle() async {
    if (_isLoading) return;
    _setIsLoading(true);
    await SignInUpWithGoogle().onError((error, stackTrace) {
      showSnackBar(context, 'Google authentication error');
      return null;
    });
    _setIsLoading(false);
  }

  // Future<void> _loginWithApple() async {
  //   if (_isLoading) return;
  //   _setIsLoading(true);
  //   await SignInWithApple().onError((e, s) async {
  //     showSnackBar(context, Messages.APPLE_AUTH_ERROR);
  //   });
  //   _setIsLoading(false);
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AuthPageHeader(),
                SignInForm(
                  setIsLoading: _setIsLoading,
                  isLoading: _isLoading,
                ),
                Text('- Or sign in with -'),
                const SizedBox(
                  height: 16,
                ),
                GoogleButton(
                  text: 'Sign in with Google',
                  onPress: _loginWithGoogle,
                ),
                const SizedBox(
                  height: 8,
                ),
                // FutureBuilder<bool>(
                //   future: TheAppleSignIn.isAvailable(),
                //   builder:
                //       (BuildContext context, AsyncSnapshot<bool> snapshot) {
                //     final bool hasAppleSignIn = snapshot.data ?? false;
                //     if (hasAppleSignIn && Platform.isIOS) {
                //       return AppleButton(
                //         text: AppleSignInUpString(_isLogin),
                //         onPress: _loginWithApple,
                //       );
                //     }
                //     return Container();
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
