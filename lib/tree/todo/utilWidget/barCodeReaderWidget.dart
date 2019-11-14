import 'package:flutter/material.dart';

import 'package:qr_mobile_vision/qr_camera.dart';

import './myCallback.dart';

class BarCodeReaderWidget extends StatelessWidget {
  BarCodeReaderWidget({this.onSeccessfulReadCallback, this.oncancelCallback});
   MCDynamicVoid onSeccessfulReadCallback;
  final MCvoidVoid oncancelCallback;

  void _qrCodeCallback(code) {
    bool qrBeenRead = onSeccessfulReadCallback == null;
    print(
        "_qrCodeCallback qrBeenRead $qrBeenRead   $qrBeenRead   $qrBeenRead   $qrBeenRead   $qrBeenRead   $qrBeenRead   qrBeenRead _qrCodeCallback");

    if (!qrBeenRead) onSeccessfulReadCallback(code);
    onSeccessfulReadCallback = null;
  }

  @override
  Widget build(BuildContext context) {
    Widget _camera = Container(
      child: // her
          QrCamera(
        fit: BoxFit.none,
        onError: (context, error) => Text(
          error.toString(),
          style: TextStyle(color: Colors.red),
        ),
        qrCodeCallback: _qrCodeCallback,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
                color: Colors.orange, width: 10.0, style: BorderStyle.solid),
          ),
        ),
      ),
    );

    return Column(
      children: <Widget>[
        Row(children: <Widget>[Text("Skann strekkode")]),
        Expanded(
            child: Center(
          child: SizedBox(
            width: 300.0,
            height: 300.0,
            child: _camera,
          ),
        )),
        RaisedButton(
          child: Text(
            "Avslutt",
          ),
          onPressed: () {
            Navigator.pop(context);

            if (oncancelCallback != null) oncancelCallback();
          },
        ),
      ],
    );
  }
}
