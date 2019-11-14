import 'package:flutter/material.dart';
import './tree/homepage.dart';
import './tree/login.dart';
import './config/auth.dart';


import './routes.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Oekonomi',
        theme: new ThemeData(
            primarySwatch: Colors.blue, accentColor: Colors.blueAccent),
        home: Router(),
        routes: routesMap // routesMap legger i filen routes
        );
  }
}

class Router extends StatefulWidget {
  @override
  _RouterState createState() => _RouterState();
}

class _RouterState extends State<Router> {
  // bool signedIn = false;
  String userID;

  @override
  void initState() {
    onAuthStateChanged();

    //To init the state of userID
    signInHandler();
    super.initState();

  }

  void signInHandler() {
    Auth.getCurrentUserID().then((res) => setState(() {
          //vil trygger build
          userID = res;
        }));
  }

  ///*************************************************************************************************
  /// Bruk enten ( den komentert ut setState-en + bool signedIn ) eller kjør onAuthStateChange "listner" inni init()
  /// for å oppdatere state
  /// */
  void signOutHandler() {
    try {
      if (userID != null) {
        Auth.signOut();
        // setState(() {
        //   signedIn = false;
        // });
      }
    } catch (e) {
      print(e);
    }
  }

  void onAuthStateChanged() {
    Auth.onAuthStateChanged().listen((user) {
      if (user == null)
        setState(() {
          // userID = user != null ? user.uid : null;
          userID = user?.uid;
        });
    });
  }

  ///************************************************************************************************* */

  @override
  Widget build(BuildContext context) {
    Widget logInPage = Login(
        onSignInCbk:
            signInHandler);  
    Widget homePage = HomePage(
      onSignOutCbk: signOutHandler,
      userID: this.userID,
    );

    return (userID != null) ? homePage : logInPage;
  }
}
