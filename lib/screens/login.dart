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
    _initDeepLinkListener();
    super.initState();
  }

  @override
  void dispose() {
    _disposeDeepLinkListener();
    loginStateSubscription.cancel();
    super.dispose();
  }

  void _initDeepLinkListener() async {
    _subs = getLinksStream().listen((String link) {

      _checkDeepLink(link);
    }, cancelOnError: true);
  }

  void _checkDeepLink(String link) {
    final authBloc =  Provider.of<AuthBloc>(context, listen: false);
    if (link != null) {
      String code = link.substring(link.indexOf(RegExp('code=')) + 5);
      print(code);
      authBloc.loginWithGitHub(code);

    }
  }


  void onClickGitHubLoginButton() async {
    const String url = "https://github.com/login/oauth/authorize" +
        "?client_id=" + CLIENT_ID;

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

  void _disposeDeepLinkListener() {
    if (_subs != null) {
      _subs.cancel();
      _subs = null;
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
                Text("Rhea Sera Rodrigues Intern at The Sparks Foundation", style: TextStyle(color: Colors.white),),

                SizedBox(height: 60,),
              ],
            ),
          ),
        )
    );
  }
}
