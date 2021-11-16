import 'package:flutter/material.dart';
import 'saved_suggestions.dart';
import 'package:english_words/english_words.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import 'autentication_notifier.dart';
import 'saved_words_notifier.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'user_profile.dart';

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final SnappingSheetController _ssController = SnappingSheetController();
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  @override
  Widget build(BuildContext context) {
    final snappingPositions = [
      SnappingPosition.factor(
        positionFactor: 0.0,
        snappingCurve: Curves.easeOutExpo,
        snappingDuration: Duration(milliseconds: 1),
        grabbingContentOffset: GrabbingContentOffset.top,
      ),
      SnappingPosition.factor(
        grabbingContentOffset: GrabbingContentOffset.bottom,
        snappingCurve: Curves.easeInExpo,
        snappingDuration: Duration(milliseconds: 1),
        positionFactor: 0.24,
      ),
    ];

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
                  if(_ssController.isAttached)
                    _ssController.snapToPosition(snappingPositions[0]);
                  const snackBar =
                      SnackBar(content: Text('Successfully logged out'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
            ),
          )
        ],
      ),
      body: Consumer<AuthRepository>(
        builder: (context, auth, _) => SnappingSheet(
          controller: _ssController,
          child: _buildSuggestions(),
          initialSnappingPosition: snappingPositions[0],
          snappingPositions: snappingPositions,
          grabbingHeight: auth.isAuthenticated
              ? MediaQuery.of(context).size.height * 0.07
              : 0,
          grabbing: !auth.isAuthenticated? SizedBox(): InkWell(
            onTap: () => setState(() {
              int position =
                  _ssController.currentSnappingPosition == snappingPositions[0]
                      ? 1
                      : 0;
              if (_ssController.isAttached)
                _ssController.snapToPosition(snappingPositions[position]);
            }),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    auth.isAuthenticated
                        ? 'Welcome back, ' + auth.user!.email!
                        : "",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Visibility(
                    visible: _ssController.isAttached &&
                        _ssController.currentSnappingPosition ==
                            snappingPositions[0],
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.black,
                    ),
                    replacement: Icon(
                      Icons.arrow_downward,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          sheetBelow: SnappingSheetContent(
            draggable: true,
            child: auth.isAuthenticated? UserProfile(): SizedBox(),
          ),
        ),
      ),
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
        builder: (context) => SavedSuggestions(),
      ),
    );
  }
}
