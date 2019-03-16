import 'dart:async';

import 'package:flutter/material.dart';
import 'ui/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  final googleSignIn = GoogleSignIn();
  final auth = FirebaseAuth.instance;

//função que verifica se o usuario está online ou faca o login
  Future<Null> _ensureLoggedIn() async {
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null) {
      user = await googleSignIn.signInSilently();
    }

    if (user == null) {
      user = await googleSignIn.signIn();
    }
    if (await auth.currentUser() == null) {
      GoogleSignInAuthentication credentials =
          await googleSignIn.currentUser.authentication;
      await auth.signInWithGoogle(
          idToken: credentials.idToken, accessToken: credentials.accessToken);
    }
  }

  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
  await _ensureLoggedIn();
}
