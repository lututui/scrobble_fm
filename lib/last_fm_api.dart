/*
import 'dart:convert';

import 'package:bustle/bustle.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:yaml/yaml.dart';

class LastFM {
  LastFM._();

  static const String kApiRoot = r'http://ws.audioscrobbler.com/2.0/';

  static Client _client;
  static String _apiKey;
  static String _apiSecret;

  static _Auth auth;
  static _User user;
  static String userAgent;

  static Future<void> init() async {
    return Future.wait([
      _loadUserAgent(),
      _loadApiKeyAndSecret(),
      _loadApiModules(),
    ]);
  }

  static Future<void> _loadUserAgent() async {
    return Future.wait([
      FlutterUserAgent.init(),
      PackageInfo.fromPlatform(),
    ]).then((value) {
      final String systemName = FlutterUserAgent.properties['systemName'];
      final String systemVersion = FlutterUserAgent.properties['systemVersion'];
      final PackageInfo packageInfo = value[1];

      assert(systemName != null && systemName.isNotEmpty);
      assert(systemVersion != null && systemVersion.isNotEmpty);
      assert(packageInfo != null &&
          packageInfo.version.isNotEmpty &&
          packageInfo.buildNumber.isNotEmpty);

      userAgent = 'ScrobbleFM/'
          '${packageInfo.version}+${packageInfo.buildNumber} '
          '($systemName $systemVersion)';

      DebugLogger.log<LastFM>('User-Agent: $userAgent');

      _client = _LastFMClient(userAgent);
    });
  }

  static Future<void> _loadApiKeyAndSecret() async {
    return rootBundle
        .loadStructuredData<YamlMap>(
      'assets/secret.yaml',
      (value) => Future.value(loadYaml(value)),
    )
        .then((yamlMap) {
      assert(yamlMap.containsKey('api_key'));
      assert(yamlMap.containsKey('api_secret'));

      _apiKey = yamlMap['api_key'];
      _apiSecret = yamlMap['api_secret'];

      assert(_apiKey.isNotEmpty);
      assert(_apiSecret.isNotEmpty);
    });
  }

  static Future<void> _loadApiModules() async {
    auth = _Auth();
    user = _User();

    return Future.wait([auth.init()]);
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
  String username;

  String get authUrl => 'https://www.last.fm/api/auth/'
      '?api_key=${LastFM._apiKey}&token=$token';

  Future<void> init() async {
    final secureStorage = FlutterSecureStorage();

    return Future.wait([
      secureStorage.read(key: 'sessionKey'),
      secureStorage.read(key: 'username')
    ]).then((values) {
      if (values.any((element) => element == null || element.isEmpty)) {
        DebugLogger.log<_Auth>('Failed to load session. Loaded: $values');

        throw Exception('Failed to load session');
      }

      sessionKey = values[0];
      username = values[1];
    }).catchError((error) {
      wipe();
    });
  }

  Future<void> wipe() async {
    final secureStorage = FlutterSecureStorage();

    return Future.wait([
      secureStorage.delete(key: 'sessionKey'),
      secureStorage.delete(key: 'username'),
    ]).then((_) {
      sessionKey = null;
      username = null;
    });
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

  Future<void> getSession() {
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
          throw Exception('Failed to get session');
        }

        assert(decodedJson['session'] is Map);

        assert(decodedJson['session'].containsKey('key'));
        assert(decodedJson['session']['key'] is String);
        assert(decodedJson['session']['key'].isNotEmpty);

        assert(decodedJson['session'].containsKey('name'));
        assert(decodedJson['session']['name'] is String);
        assert(decodedJson['session']['name'].isNotEmpty);

        sessionKey = decodedJson['session']['key'];
        username = decodedJson['session']['name'];
        return FlutterSecureStorage()
          ..write(key: 'sessionKey', value: sessionKey)
          ..write(key: 'username', value: username);
      },
    );
  }
}

class _User {
  Future<void> getInfo([String username]) {
    return LastFM._client.post(
      _requestURL,
      body: _buildBodyRequest(
        r'user.getinfo',
        {'user': username ?? LastFM.auth.username},
      ),
    ).then((value) {
      final decodedJson = _decode(value);

      print(decodedJson);
    });
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
*/
