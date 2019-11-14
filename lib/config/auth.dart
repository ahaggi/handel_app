import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Auth {
  static Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    FirebaseUser user;
    try {
      AuthResult res = (await _auth.signInWithEmailAndPassword(
          email: email, password: password));
      user = res.user;
    } catch (e) {
      print("Auth.signInWithEmailAndPassword  $e");
      throw (e);
    }
    // return user != null ? user.uid : null;
    return user?.uid;
  }

  static Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    FirebaseUser user;
    try {
      AuthResult res = (await _auth.createUserWithEmailAndPassword(
          email: email, password: password));
      user = res.user;
    } catch (e) {
      print("Auth.createUserWithEmailAndPassword  $e");
      throw (e);
    }
    return user?.uid;
  }

  // static Future<bool> emailAlreadyExists(email) async {
  //   List<String> users = await _auth.fetchProvidersForEmail(email: email);
  //   return (users.length != 0);
  // }

  // static Future<bool> isSignedIn() async {
  //   FirebaseUser user = await _auth.currentUser();
  //   return user != null;
  // }

  static Future<String> getCurrentUserID() async {
    FirebaseUser user = await _auth.currentUser();
    // return user != null ? user.uid : null;
    return user?.uid;
  }

  static Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
  }

  static Future<void> signOut() async {
    bool b = (await getCurrentUserID()) != null;
    if (b) _auth.signOut();
  }

  static Stream<FirebaseUser> onAuthStateChanged() {
    return _auth.onAuthStateChanged;
  }
}
