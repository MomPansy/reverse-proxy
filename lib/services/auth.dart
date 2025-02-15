// ignore_for_file: file_names, non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/show_snackbar.dart';

//TODO implement sign in with apple

Future<void> Login({
  required BuildContext context,
  required String email,
  required String password,
}) async {
  try {
    await LoginWithUsernameAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      showSnackBar(context, 'No user found');
    } else if (e.code == 'user-disabled') {
      showSnackBar(context,'Account suspended');
    } else if (e.code == 'wrong-password') {
      showSnackBar(context, 'Wrong password');
    }
  }
}

Future<UserCredential> LoginWithUsernameAndPassword({
  required String email,
  required String password,
}) async {
  return await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}

Future<void> SignUp({
  required BuildContext context,
  required String email,
  required String password,
}) async {
  try {
    await CreateUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      LoginWithUsernameAndPassword(email: email, password: password)
          .then((userCredentials) async {
        await userCredentials.user!.sendEmailVerification();
        await SignOut();
      });
    });
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      showSnackBar(context, 'Account already exists');
    }
  } catch (e) {
    showSnackBar(context, 'Error occurred, please try again');
  }
}

Future<UserCredential> CreateUserWithEmailAndPassword({
  required String email,
  required String password,
}) async {
  return await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
}

Future<UserCredential?> SignInUpWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception("Not logged in");
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {

  }
  return null;
}

Future<AuthCredential?> GetGoogleCredentials() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signInSilently();
  if (googleUser == null) throw Exception("Not logged in");
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  return GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
}

void ReAuthenticate(BuildContext context) {
  FirebaseAuth.instance.currentUser?.reload().catchError((error) {
    showSnackBar(context, 'Unable to retrieve account');
    SignOut();
  });
}

Future<void> SignOut() async {
  if (await GoogleSignIn().isSignedIn()) {
    GoogleSignIn().disconnect();
  }
  await FirebaseAuth.instance.signOut();
}

Future<void> ShowSuspendedAndSignOut(BuildContext context) async {
  showSnackBar(context, 'Account suspended');
  SignOut();
}

Future<bool?> CheckAccountHasPassword() async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  bool hasPassword = false;
  for (final providerProfile in user.providerData) {
    final provider = providerProfile.providerId;
    if (provider == 'password') {
      hasPassword = true;
    }
  }
  return hasPassword;
}

Future<List<String>> CheckAccountAuthProvider() async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];
  List<String> providerIds = [];
  for (final providerProfile in user.providerData) {
    final provider = providerProfile.providerId;
    providerIds.add(provider);
  }
  return providerIds;
}
