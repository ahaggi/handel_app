import 'package:flutter/material.dart';
import 'package:handle_app/config/auth.dart';

enum FormType { LOGIN, REGISTER }

class Login extends StatefulWidget {
  Login({this.onSignInCbk}); // constructor
  final VoidCallback onSignInCbk;
  @override
  _LoginState createState() => new _LoginState();
}

class _LoginState extends State<Login> {
  Map<String, dynamic> err = {
    "ERROR_EMAIL_ALREADY_IN_USE": false,
    "ERROR_WEAK_PASSWORD": false,
    "ERROR_INVALID_EMAIL": false,
    "ERROR_WRONG_PASSWORD": false,
    "ERROR_USER_NOT_FOUND": false,
    "ERROR_USER_DISABLED": false,
  };

  Map<String, dynamic> state = {
    "username": "",
    "password": "",
    "checkbox": false,
    "fromtype": FormType.LOGIN,
    "err": {}
  };

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {

    state["err"] = err;
    super.initState();

  }

  void moveToRegister() {
    setState(() {
      state["fromtype"] = FormType.REGISTER;
    });
    print("moveToRegister() ,,, $state");
  }

  void moveToLogin() {
    setState(() {
      state["fromtype"] = FormType.LOGIN;
    });
    print("moveToLogin() ,,, $state");
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save(); //to invoke each FormField's onSaved callback
      print("valid, $state");
      return true;
    }

    return false;
  }

  void validAndSubmitLogin() async {
    if (validateAndSave())
      try {
        String userUid = await Auth.signInWithEmailAndPassword(
            state["username"], state["password"]);
        if (userUid != null) {
          widget.onSignInCbk();
          print("Signed in as: $userUid");
        }
      } catch (e) {
        print("Rcvd error:$e ");
        setSignInErrors(e);
      }
  }

  void validAndSubmitCreateAnAcct() async {
    if (validateAndSave())
      try {
        String userUid = await Auth.createUserWithEmailAndPassword(
            state["username"], state["password"]);
        print("New acct has been craeted user id: $userUid");
        if (userUid != null) {
          widget.onSignInCbk();
          print("Signed in as: $userUid");
        }
      } catch (e) {
        print("Rcvd error:$e ");
        setSignUpErrors(e);
      }
  }

  void setSignInErrors(e) {
    if (e.code == "ERROR_INVALID_EMAIL")
      state["err"]["ERROR_INVALID_EMAIL"] = true;

    if (e.code == "ERROR_WRONG_PASSWORD")
      state["err"]["ERROR_WRONG_PASSWORD"] = true;

    if (e.code == "ERROR_USER_NOT_FOUND")
      state["err"]["ERROR_USER_NOT_FOUND"] = true;

    if (e.code == "ERROR_USER_DISABLED")
      state["err"]["ERROR_USER_DISABLED"] = true;

    formKey.currentState
        .validate(); // to invoke each FormField's validate callback.
  }

  void setSignUpErrors(e) {
    if (e.code == "ERROR_EMAIL_ALREADY_IN_USE")
      state["err"]["ERROR_EMAIL_ALREADY_IN_USE"] = true;

    if (e.code == "ERROR_WEAK_PASSWORD")
      state["err"]["ERROR_WEAK_PASSWORD"] = true;

    formKey.currentState
        .validate(); // to invoke each FormField's validate callback.
  }

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      'resources/images/login.png',
      width: 120.0,
      height: 120.0,
      fit: BoxFit.cover,
    );

    Widget username = TextFormField(
      decoration: InputDecoration(labelText: 'User Name'),
      initialValue: "a@a.com",
      validator: (value) {
        String err = "";

        if (state["fromtype"] == FormType.REGISTER)
          err += state['err']['ERROR_EMAIL_ALREADY_IN_USE']
              ? 'The email address is already in use by another account.'
              : '';
          err += state['err']['ERROR_INVALID_EMAIL']
              ? 'The email address is not valid.'
              : '';
          err += state['err']['ERROR_USER_NOT_FOUND']
              ? 'There is no user record corresponding to this account.'
              : '';
          err += state['err']['ERROR_USER_DISABLED']
              ? 'The user account has been disabled.'
              : '';

        if (value.isEmpty) err += 'User name is req';
        return err == "" ? null : err;
      },
      onSaved: (value) => state["username"] = value,
    );

    Widget password = TextFormField(
      decoration: InputDecoration(labelText: 'Password'),
      initialValue: "123456",
      validator: (value) {
        String err = "";

        err += value.isEmpty ? 'Password is req' : '';
        err += state['err']['ERROR_WEAK_PASSWORD']
            ? 'Password should be at least 6 characters.'
            : '';
        err += state['err']['ERROR_WRONG_PASSWORD']
            ? 'The password is invalid.'
            : '';
        return err == "" ? null : err;
      },
      onSaved: (value) => state["password"] = value,
      obscureText: true,
    );

    Widget btnLogin = Container(
      margin: const EdgeInsets.all(20.0),
      child: RaisedButton(
          child: Text(
            'Login',
            style: TextStyle(fontSize: 20.0),
          ),
          onPressed: validAndSubmitLogin),
    );

    Widget btnCreateAnAcct = Container(
      margin: const EdgeInsets.all(20.0),
      child: RaisedButton(
          color: Colors.blue,
          child: Text(
            'Create New Account',
            style: TextStyle(fontSize: 20.0),
          ),
          onPressed: validAndSubmitCreateAnAcct),
    );

    Widget submit = state["fromtype"] == FormType.LOGIN
        ? btnLogin
        : (state["fromtype"] == FormType.REGISTER ? btnCreateAnAcct : null);

    Widget checkBox =
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Checkbox(
          value: state['checkbox'],
          onChanged: (bool value) {
            setState(() {
              state['checkbox'] = value;
            });
          }),
      Text('qwqe wqe qweq ')
    ]);

    Widget linkCreateNewAcct = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(child: new Text('Cerate new account'), onTap: moveToRegister)
        ]);

    Widget linkHaveAnAcct = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(child: new Text('I have an account'), onTap: moveToLogin)
        ]);

    Widget linkAcct = state["fromtype"] == FormType.LOGIN
        ? linkCreateNewAcct
        : (state["fromtype"] == FormType.REGISTER ? linkHaveAnAcct : null);

    Widget linkForgotPassword = Column(children: <Widget>[
      InkWell(child: new Text('Forgot password?'), onTap: () {})
    ]);

    Widget form = Container(
      padding: EdgeInsets.all(20.0),
      child: Form(
          key: formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                username,
                password,
                checkBox,
                submit,
                Row(
                  children: <Widget>[
                    Expanded(child: linkAcct),
                    linkForgotPassword
                  ],
                ),
              ])),
    );

    Widget pageBody = ListView(
      // reverse: true,
      children: <Widget>[
        Column(children: <Widget>[image, form])
      ] //.reversed.toList()
          ,
    );

    return Scaffold(
        appBar: AppBar(title: Text('Login Page'), actions: <Widget>[
          IconButton(
              icon: Icon(Icons.list),
              onPressed: (() {
                print("Login page actions button");
              }))
        ]),
        body: Container(
          child: pageBody,
        ));
  }
}
