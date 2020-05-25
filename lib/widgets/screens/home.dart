import 'package:flutter/material.dart';
import 'package:scrobble_fm/last_fm_api.dart';
import 'package:scrobble_fm/main.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kAppName),
        actions: <Widget>[
          PopupMenuButton<_HomeOptions>(
            onSelected: (option) {
              LastFM.auth
                  .wipe()
                  .then((_) => Navigator.of(context).pushReplacementNamed('/'));
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: _HomeOptions.logout, child: Text('Logout'))
              ];
            },
          ),
        ],
      ),
      body: Center(child: Text('Logged in!')),
    );
  }
}

enum _HomeOptions {
  logout,
}
