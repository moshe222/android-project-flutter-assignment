import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:startup_moshe/autentication_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedWords with ChangeNotifier {
  final List<WordPair> _list;
  String? _userID;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<WordPair> get list => _list;

  SavedWords.instance() : _list = [];

  WordPair _string2Pair(String str) {
    int capital = str.lastIndexOf(RegExp(r'[A-Z]'));
    String first = str.substring(0, capital).toLowerCase();
    String second = str.substring(capital).toLowerCase();
    return WordPair(first, second);
  }

  void update(AuthRepository auth) {
    if (auth.status == Status.Authenticated) {
      _userID = auth.user!.uid;

      final List<WordPair> cpy = [..._list];

      _db.collection('saved').doc(_userID).get().then((doc) async {
        if (doc.exists) {
          List<dynamic> names = doc['names'];
          await Future.forEach(names, (str) {
            WordPair pair = _string2Pair(str as String);
            if (!_list.contains(pair)) {
              _list.add(pair);
            }
          });
        }
      }).then((value) async {
        Future.forEach(cpy, (pair) async => await _addToDB(pair as WordPair));
      }).whenComplete(() => notifyListeners());
    } else if (_userID != null && auth.status == Status.Unauthenticated) {
      _list.clear();
      _userID = null;
      notifyListeners();
    }
  }

  void addPair(WordPair pair) {
    _list.add(pair);
    notifyListeners();

    if (_userID != null) {
      _addToDB(pair);
    }
  }

  Future<void> _addToDB(WordPair pair) async {
    final doc = await _db.collection('saved').doc(_userID).get();
    if (!doc.exists) {
      _db.collection('saved').doc(_userID).set({
        'names': [pair.asPascalCase]
      });
    } else {
      _db.collection('saved').doc(_userID).update({
        'names': FieldValue.arrayUnion([pair.asPascalCase])
      });
    }
  }

  void removePair(WordPair pair) {
    _list.remove(pair);
    notifyListeners();

    if (_userID != null) {
      _db.collection('saved').doc(_userID).update({
        'names': FieldValue.arrayRemove([pair.asPascalCase])
      });
    }
  }

  bool contains(WordPair pair) => _list.contains(pair);
}
