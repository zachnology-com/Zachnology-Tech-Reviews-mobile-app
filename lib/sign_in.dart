import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_oauth/firebase_auth_oauth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:github_sign_in/github_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();


bool authSignedIn;
String uid;
String name;
String twitterName;


Future<String> signInWithGoogle() async {
  await Firebase.initializeApp();

  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult =
      await _auth.signInWithCredential(credential);
  final User user = authResult.user;

  if (user != null) {
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);
    name = user.displayName;
    print('signInWithGoogle succeeded: $user');

    return '$user';
  }

  return null;
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();
  googleSignIn.disconnect();
  await FirebaseAuth.instance.signOut();
  print("User Signed Out");
}

Future<UserCredential> signInWithTwitter() async {
  // Create a TwitterLogin instance
  final TwitterLogin twitterLogin = new TwitterLogin(
    consumerKey: '<your consumer key>',
    consumerSecret:' <your consumer secret>',
  );

  // Trigger the sign-in flow
  final TwitterLoginResult loginResult = await twitterLogin.authorize();

  // Get the Logged In session
  final TwitterSession twitterSession = loginResult.session;

  // Create a credential from the access token
  final AuthCredential twitterAuthCredential =
  TwitterAuthProvider.credential(accessToken: twitterSession.token, secret: twitterSession.secret);
  await FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);

  twitterName = FirebaseAuth.instance.currentUser.displayName;
  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);
}

