import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:provider/provider.dart';
import 'package:socialmediainteractions/blocs/authbloc.dart';
import 'package:socialmediainteractions/screens/login.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<User> loginStateSubscription;

  @override
  void initState() {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    loginStateSubscription = authBloc.currentUser.listen((fbUser) {
      if (fbUser == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
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

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);

    return Scaffold(
        body: Container(
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage( "images/backgroundImage.png"), fit: BoxFit.cover)),
          child: Center(
            child: StreamBuilder<User>(
                stream: authBloc.currentUser,
                builder: (context, snapshot) {
                  print("SNAPSHOT RHEA"+snapshot.toString());
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  print(snapshot.data.photoURL);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(snapshot.data.providerData[0].displayName == null ? "":snapshot.data.providerData[0].displayName,style:TextStyle(fontSize: 35.0,color: Colors.white)),
                      SizedBox(height: 20.0,),
                      Text(snapshot.data.email == null ? "":snapshot.data.email,style:TextStyle(fontSize: 20.0,color: Colors.white)),
                      SizedBox(height: 20.0,),
                      CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data.photoURL.replaceFirst('s96','s400')),
                        radius: 60.0,
                      ),
                      SizedBox(height: 100.0,),
                  Column(children: <Widget>[
                  if(snapshot.data.providerData[0].providerId.toString()=='facebook.com')
                    SignInButton(
                    Buttons.Facebook,
                    text: 'Sign Out of Facebook',
                    onPressed: () => authBloc.logout()
                    ),
                  if(snapshot.data.providerData[0].providerId.toString()=='google.com')
                    SignInButton(
                    Buttons.Google,
                    text: 'Sign Out of Google',
                    onPressed: () => authBloc.logout()
                    ),
                    if(snapshot.data.providerData[0].providerId.toString()=='github.com')
                      SignInButton(
                          Buttons.GitHub,
                          text: 'Sign Out of Github',

                          onPressed: () => authBloc.logout()
                      ),
                  ],)


                    ],
                  );
                }
            ),
          ),
        ));
  }
}