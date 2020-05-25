import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:scrobble_fm/last_fm_api.dart';
import 'package:scrobble_fm/main.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> _token;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kAppName)),
      body: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (_token != null) return;

            setState(
              () {
                _token = LastFM.auth
                  .getToken()
                  .then((_) => authorizeToken(context, LastFM.auth.authUrl));
              },
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(kAppName, style: Theme.of(context).textTheme.headline2),
              if (_token == null)
                Text(
                  'Tap anywhere to login',
                  style: Theme.of(context).textTheme.subtitle1,
                )
              else
                CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  void authorizeToken(BuildContext context, String authUrl) {
    Navigator.of(context)
        .pushNamed('/loginWebView', arguments: authUrl)
        .then((_) => LastFM.auth.getSession())
        .then(
      (sessionKey) {
        if (sessionKey == null) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to retrieve token. Please try again'),
            ),
          );

          setState(() {
            _token = null;
          });

          return;
        }

        SchedulerBinding.instance.addPostFrameCallback(
          (_) => Navigator.of(context).pushReplacementNamed('/'),
        );
      },
    );
  }
}
