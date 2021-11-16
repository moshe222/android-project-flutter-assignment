import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startup_moshe/autentication_notifier.dart';
import 'password_confirmation.dart';

class LoginScreen extends StatelessWidget {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery
              .of(context)
              .size
              .width * 0.04,
          vertical: MediaQuery
              .of(context)
              .size
              .height * 0.04,
        ),
        height: MediaQuery
            .of(context)
            .size
            .height * 0.43,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Welcome to Startup Names Generator, please login below",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _email,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User Name',
                  hintText: 'Enter valid User Name'),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter your secure password'),
            ),
            Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.05,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.7,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Consumer<AuthRepository>(
                builder: (context, auth, _) =>
                    TextButton(
                      onPressed: auth.status == Status.Authenticating
                          ? null
                          : () async {
                        if (await auth.signIn(_email.text, _password.text)) {
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'There was an error logging into the app')),
                          );
                        }
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
              ),
            ),
            Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.05,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.7,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Consumer<AuthRepository>(
                builder: (context, auth, _) =>
                    TextButton(
                      onPressed: auth.status == Status.Authenticating
                          ? null
                          : () async {
                        showModalBottomSheet<void>(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) => PasswordConfirmation(_email.text, _password.text)
                        );
                      },
                      child: const Text(
                        'New user? Click to sign up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
