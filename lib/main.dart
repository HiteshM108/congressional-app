import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/screens/wrapper.dart';
import 'package:flutter_test_app/screens/authenticate/userSetup.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCh4NJDWo0dH88lRNh6kYm8lpn8WqGAvZ8", // paste your api key here
      appId: "1:798027375262:android:3760e0cc3ac8c59c7bd18f", //paste your app id here
      messagingSenderId: "798027375262", //paste your messagingSenderId here
      projectId: "nutritrack-e19cd", //paste your project id here
    ),
  );

  runApp(MaterialApp(
    title: 'Named Routes',
    routes: {
      '/setup': (context) => UserInfoSetup(),
    },
    home: Wrapper()
  ));
}

class App extends StatelessWidget {

  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: Wrapper()
    );
  }
}
