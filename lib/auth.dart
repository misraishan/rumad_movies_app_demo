import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

// 3. Create a class called AuthScreen
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  void finishSigning(AuthResponse response) {
    Navigator.popAndPushNamed(context, "/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SupaEmailAuth(
                  onSignInComplete: finishSigning,
                  onSignUpComplete: finishSigning),
            ],
          ),
        ),
      ),
    );
  }
}
