import 'package:flutter/material.dart';
import 'package:scrobble_fm/last_fm_api.dart';
import 'package:scrobble_fm/widgets/screens/home.dart';
import 'package:scrobble_fm/widgets/screens/login.dart';
import 'package:scrobble_fm/widgets/screens/login_web_view.dart';

const String kAppName = 'ScrobbleFM';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([LastFM.init()]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          if (LastFM.auth.sessionKey != null) {
            return MaterialPageRoute(builder: (context) => HomeScreen());
          }

          return MaterialPageRoute(builder: (context) => LoginScreen());
        }

        if (settings.name == '/loginWebView') {
          return MaterialPageRoute(
            builder: (context) => LoginWebViewScreen(
              loginUrl: settings.arguments as String,
            ),
          );
        }

        throw Exception('Unknown route with name ${settings.name}');
      },
    );
  }
}
