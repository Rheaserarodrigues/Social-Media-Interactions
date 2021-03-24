import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../model/github_login_request.dart';
import '../model/github_login_response.dart';

class AuthBloc {


  final authService = AuthService();

  final fb = FacebookLogin();
  //Google Sign In
  final googleSignin = GoogleSignIn(scopes: ['email']);


  Stream<User> get currentUser => authService.currentUser;

  loginGoogle() async {

    try {
      final GoogleSignInAccount googleUser = await googleSignin.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken
      );

      //Firebase Sign in
      final result = await authService.signInWithCredential(credential);
      print("The RESULT "+result.toString());
      print('${result.user.displayName}');

    } catch(error){
      print(error);
    }

  }

  logout() {
    authService.logout();
  }


  loginFacebook() async {
    print('Starting Facebook Login');
    final res = await fb.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

// Check result status
    switch (res.status) {
      case FacebookLoginStatus.success:
      // Logged in

      // Send access token to server for validation and auth
        final FacebookAccessToken accessToken = res.accessToken;
        print('Access token: ${accessToken.token}');

        //Convert to Auth Credential
        final AuthCredential credential
        = FacebookAuthProvider.credential(accessToken.token);

        //User Credential to Sign in with Firebase
        final result = await authService.signInWithCredential(credential);
        // Get profile data
        final profile = await fb.getUserProfile();
        print('Hello, ${profile.name}! You ID: ${profile.userId}');

        // Get user profile image url
        final imageUrl = await fb.getProfileImageUrl(width: 100);
        print('Your profile image: $imageUrl');

        // Get email (since we request email permission)
        final email = await fb.getUserEmail();
        // But user can decline permission
        if (email != null)
          print('And your email is $email');

        break;
      case FacebookLoginStatus.cancel:
      // User cancel log in
        break;
      case FacebookLoginStatus.error:
      // Log in failed
        print('Error while log in: ${res.error}');
        break;
    }
  }


   loginWithGitHub(String code) async {
    String CLIENT_ID = "4deda9a7a0d24473cf44";
    String CLIENT_SECRET = "705393323712a87724f8f092c924c573b4601e81";
    //ACCESS TOKEN REQUEST
    final response = await http.post(
      Uri.parse("https://github.com/login/oauth/access_token"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode(GitHubLoginRequest(
        clientId: CLIENT_ID,
        clientSecret: CLIENT_SECRET,
        code: code,
      )),
    );

    GitHubLoginResponse loginResponse = GitHubLoginResponse.fromJson(json.decode(response.body));

    //FIREBASE SIGNIN
    final auth.AuthCredential credential = auth.GithubAuthProvider.credential(loginResponse.accessToken);

    final result = await authService.signInWithCredential(credential);

  }






  }