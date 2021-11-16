import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'autentication_notifier.dart';
import 'saved_words_notifier.dart';
import 'random_words.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final wordPair = WordPair.random()

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthRepository>(
          create: (_) => AuthRepository.instance(),
        ),
        ChangeNotifierProxyProvider<AuthRepository, SavedWords>(
          create: (_) => SavedWords.instance(),
          update: (_, auth, saved) => saved!..update(auth),
        )
      ],
      child: MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
          // Add the 5 lines from here...
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        home: RandomWords(),
      ),
    );
  }
}
