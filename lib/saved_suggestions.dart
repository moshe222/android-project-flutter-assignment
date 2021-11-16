import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'saved_words_notifier.dart';

class SavedSuggestions extends StatelessWidget {
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
