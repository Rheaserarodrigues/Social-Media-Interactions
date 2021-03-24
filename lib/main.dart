import 'package:flutter/material.dart';
import './screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import './blocs/authbloc.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context)=>AuthBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(

          primarySwatch: Colors.blue,),
        home: LoginScreen(),
      ),
    );
  }
}


