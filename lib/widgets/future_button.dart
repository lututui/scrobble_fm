import 'dart:async';

import 'package:flutter/material.dart';

class FutureButton<T> extends StatefulWidget {
  const FutureButton({Key key, this.onPressed, this.child, this.onDone})
      : super(key: key);

  final Future<T> Function() onPressed;
  final void Function(T) onDone;
  final Widget child;

  @override
  _FutureButtonState createState() => _FutureButtonState<T>();
}

class _FutureButtonState<T> extends State<FutureButton<T>> {
  Future<T> _listen;

  @override
  void didUpdateWidget(FutureButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.onPressed != widget.onPressed) {
      _listen = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _listen != null,
      child: RaisedButton(
        onPressed: widget.onPressed == null
            ? null
            : () {
                assert(_listen == null);

                setState(() {
                  _listen = widget.onPressed();
                });
              },
        child: FutureBuilder<T>(
          future: _listen,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.none) {
              return widget.child;
            }

            if (snapshot.connectionState == ConnectionState.done) {
              widget.onDone(snapshot.data);
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
