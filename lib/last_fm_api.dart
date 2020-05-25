import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart';
import 'package:yaml/yaml.dart';

class LastFM {
  LastFM._();

  static const String kApiRoot = r'http://ws.audioscrobbler.com/2.0/';

  static Client _client;
  static String _apiKey;
  static String _apiSecret;

  static _Auth auth;
  static String userAgent;

  static Future<void> init() async {
    return FlutterUserAgent.init()
        .then((_) {
          final properties = FlutterUserAgent.properties;

          userAgent = 'ScrobbleFM/1.0.0+1 (${properties['systemName']} '
              '${properties['systemVersion']})';

          _client = _LastFMClient(userAgent);
          auth = _Auth();

          return auth.init();
        })
        .then((_) => rootBundle.loadStructuredData<YamlMap>(
              'assets/secret.yaml',
              (value) => Future.value(loadYaml(value)),
            ))
        .then((yamlMap) {
          assert(yamlMap.containsKey('api_key'));
          assert(yamlMap.containsKey('api_secret'));

          _apiKey = yamlMap['api_key'];
          _apiSecret = yamlMap['api_secret'];
        });
  }
}

class _LastFMClient extends BaseClient {
  final Client _internalClient;
  final String _userAgent;

  _LastFMClient(this._userAgent) : _internalClient = Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return _internalClient.send(request..headers['user-agent'] = _userAgent);
  }
}

class _Auth {
  String token;
  String sessionKey;

  String get authUrl => 'https://www.last.fm/api/auth/'
      '?api_key=${LastFM._apiKey}&token=$token';

  Future<void> init() async {
    return FlutterSecureStorage().read(key: 'sessionKey').then(
      (value) {
        if (value == null || value.isEmpty) return;

        sessionKey = value;
      },
    );
  }

  Future<void> wipe() async {
    assert(token == null);
    assert(sessionKey != null);
    return FlutterSecureStorage().delete(key: 'sessionKey').then(
      (_) {
        sessionKey = null;
      },
    );
  }

  Future<String> getToken() async {
    assert(sessionKey == null);

    return LastFM._client
        .post(_requestURL, body: _buildBodyRequest(r'auth.gettoken'))
        .then((value) {
      final decodedJson = _decode(value);

      assert(decodedJson.containsKey('token'));
      assert(decodedJson['token'] is String);
      assert(decodedJson['token'].isNotEmpty);

      return token = decodedJson['token'];
    });
  }

  Future<String> getSession() {
    assert(token != null);
    assert(sessionKey == null);

    return LastFM._client
        .post(
      _requestURL,
      body: _buildBodyRequest(r'auth.getsession', {'token': token}),
    )
        .then(
      (value) {
        token = null;

        final decodedJson = _decode(value);

        if (!decodedJson.containsKey('session')) {
          return null;
        }

        assert(decodedJson['session'] is Map);
        assert(decodedJson['session'].containsKey('key'));
        assert(decodedJson['session']['key'] is String);
        assert(decodedJson['session']['key'].isNotEmpty);

        sessionKey = decodedJson['session']['key'];
        FlutterSecureStorage().write(key: 'sessionKey', value: sessionKey);
        return sessionKey;
      },
    );
  }
}

Map<String, String> _buildBodyRequest(
  String method, [
  Map<String, String> args,
]) {
  final unsignedBody = {
    'method': method,
    'api_key': LastFM._apiKey,
    if (args != null) ...args,
  };

  final sortedKeysList = unsignedBody.keys.toList()..sort();
  final signature = StringBuffer();

  for (final key in sortedKeysList) {
    signature.write('$key${unsignedBody[key]}');
  }

  signature.write(LastFM._apiSecret);

  return {
    ...unsignedBody,
    'api_sig': md5.convert(utf8.encode(signature.toString())).toString(),
  };
}

String _requestURL = '${LastFM.kApiRoot}?format=json';

Map<String, dynamic> _decode(Response response) {
  if (response.body == null || response.body.isEmpty) {
    throw FormatException('Request returned empty body');
  }

  final decodedJson = json.decode(response.body);

  if (decodedJson == null) {
    throw FormatException(
      'Response failed to parse as JSON.\n'
      'Response body: ${response.body}\n'
      'Parsed to: $decodedJson',
    );
  }

  return decodedJson;
}
