import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'autentication.dart';
import 'saved_words.dart';

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
        home: const RandomWords(),
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  @override
  Widget build(BuildContext context) {
    //final wordPair = WordPair.random();
    return Scaffold(
      // Add from here...
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _pushSaved,
            tooltip: 'Saved Suggestions',
          ),
          Consumer<AuthRepository>(
            builder: (context, auth, _) => Visibility(
              visible: !auth.isAuthenticated,
              child: IconButton(
                icon: const Icon(Icons.login),
                onPressed: _pushLogin,
              ),
              replacement: IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () {
                  auth.signOut();
                  const snackBar =
                      SnackBar(content: Text('Successfully logged out'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
            ),
          )
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildRow(WordPair pair) {
    return Consumer<SavedWords>(
      builder: (context, saved, _) => ListTile(
        title: Text(
          pair.asPascalCase,
          style: _biggerFont,
        ),
        trailing: Icon(
          // NEW from here...
          saved.contains(pair) ? Icons.star : Icons.star_border,
          color: saved.contains(pair) ? Colors.deepPurple : null,
          semanticLabel: saved.contains(pair) ? 'Remove from saved' : 'Save',
        ),
        onTap: () {
          if (!saved.contains(pair)) {
            saved.addPair(pair);
          } else {
            saved.removePair(pair);
          }
        },
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return const Divider();
          }
          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  void _pushLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Saved Suggestions'),
          ),
          body: Consumer<SavedWords>(
            builder: (context, saved, _) {
              return ListView.separated(
                itemBuilder: (_, index) => Dismissible(
                  key: Key(saved.list[index].asPascalCase),
                  child: ListTile(
                    title: Text(
                      saved.list[index].asPascalCase,
                      style: _biggerFont,
                    ),
                  ),
                  background: Container(
                    color: Colors.deepPurple,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: const [
                          Icon(Icons.delete, color: Colors.white),
                          Text('Delete Suggestion',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  confirmDismiss: (DismissDirection direction) async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text("Delete Suggestion"),
                        content: Text("Are you sure you want to delete " +
                            saved.list[index].asPascalCase +
                            " from your saved suggestions?"),
                        actions: [
                          TextButton(
                              child: Text("Yes"),
                              onPressed: () {
                                saved.removePair(saved.list[index]);
                                Navigator.of(context).pop();
                              }),
                          TextButton(
                            child: Text("No"),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ],
                      ),
                    );
                  },
                ),
                separatorBuilder: (_, __) => const Divider(),
                itemCount: saved.list.length,
              );
            },
          ),
        ),
      ),
    );
  }
}
