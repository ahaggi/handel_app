import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoadingIndicatorWidget extends StatelessWidget {
  LoadingIndicatorWidget(
      {@required this.waitingDur, @required this.onCancelCallback});
  final int waitingDur;
  final dynamic onCancelCallback;

  Widget _loadingIndicator(context) {
    FocusScope.of(context)
        .requestFocus(new FocusNode()); // To remove the keyboard
    Future _cancel = Future.delayed(Duration(seconds: waitingDur), () => null);

    return Container(
      alignment: AlignmentDirectional.center,
      decoration: BoxDecoration(
        color: Colors.white70,
      ),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.blue[200], borderRadius: BorderRadius.circular(10.0)),
        width: 300.0,
        height: 200.0,
        alignment: AlignmentDirectional.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(
                value: null,
                strokeWidth: 10.0,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 25.0),
              child: Text(
                "loading.. wait...",
                style: TextStyle(color: Colors.white),
              ),
            ),
            FutureBuilder(
              future: _cancel,
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.done)
                  return Container(
                    margin: const EdgeInsets.only(top: 25.0),
                    child: RaisedButton(
                      child: Text("Avslutt!"),
                      onPressed: (onCancelCallback != null)
                          ? onCancelCallback
                          : null,
                    ),
                  );
                else
                  return Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loadingIndicator(context);
  }
}
