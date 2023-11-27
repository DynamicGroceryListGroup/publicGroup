import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_test/screens/authentication/signin_screen.dart';
import 'package:firebase_test/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading indicator while checking authentication status.
        } else if (snapshot.hasData) {
          return CupertinoApp(
            home: HomeScreen(),
            theme: CupertinoThemeData(
              primaryColor: Color.fromARGB(255, 0, 128, 64), // British Racing Green
            ),
          );
        } else {
          return MaterialApp( // Use MaterialApp for SignInScreen
            home: SignInScreen(), // Redirect to the login screen if the user is not authenticated.
          );
        }
      },
    );
  }
}
