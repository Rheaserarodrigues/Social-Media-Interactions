import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:socialmediainteractions/blocs/authbloc.dart';
import 'package:socialmediainteractions/screens/home.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String CLIENT_ID = "4deda9a7a0d24473cf44";
  static const String CLIENT_SECRET = "705393323712a87724f8f092c924c573b4601e81";
  StreamSubscription _subs;
  StreamSubscription<User> loginStateSubscription;

  @override
  void initState() {
    _initDeepLinkListener();
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    loginStateSubscription = authBloc.currentUser.listen((fbUser) {
      if (fbUser != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    loginStateSubscription.cancel();
    super.dispose();
  }

  void _initDeepLinkListener() async {
    _subs = getLinksStream().listen((String link) {
      _checkDeepLink(link);
    }, cancelOnError: true);
  }

  void _checkDeepLink(String link) {
    final authBloc = Provider.of<AuthBloc>(context);
    if (link != null) {
      String code = link.substring(link.indexOf(RegExp('code=')) + 5);
      authBloc.loginWithGitHub(code);

    }
  }


  void onClickGitHubLoginButton() async {
    const String url = "https://github.com/login/oauth/authorize" +
        "?client_id=" + CLIENT_ID +
        "&scope=public_repo%20read:user%20user:email";

    if (await canLaunch(url)) {

      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {

      print("CANNOT LAUNCH THIS URL!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage( "images/backgroundImage.png"), fit: BoxFit.cover)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SignInButton(
                  Buttons.Google,
                  onPressed: () => authBloc.loginGoogle(),
                ),
                SizedBox(height: 10,),
                SignInButton(Buttons.GitHub,
                    onPressed: () => onClickGitHubLoginButton()),
                SizedBox(height: 10,),
                SignInButton(Buttons.Facebook,
                    onPressed: () => authBloc.loginFacebook()),
                SizedBox(height: 10,),
                SignInButton(Buttons.Apple,
                    onPressed: () => {}),
              ],
            ),
          ),
        ));
  }
}
