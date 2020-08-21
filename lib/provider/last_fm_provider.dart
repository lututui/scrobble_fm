import 'package:flutter/material.dart';
import 'package:scrobblenaut/scrobblenaut.dart';

class LastFMProvider extends ChangeNotifier {
  LastFMProvider._();

  static Future<void> create() async {
    LastFM.authenticate(apiKey: null, apiSecret: null, username: null, password: null);
  }
}