import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());

const biggerFont = TextStyle(fontSize: 18.0);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.amber,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
          body: MyHomePage(
        title: 'Name Generator',
      )),
      // home: MyHomePage(title: 'Name Generator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final savedSuggestions = <WordPair>[];

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (BuildContext context) {
        final tiles = savedSuggestions.map(
          (WordPair pair) {
            return new Builder(builder: (context) {
              return Dismissible(
                background: Container(color: Colors.red),
                key: Key(pair.asPascalCase),
                onDismissed: (direction) {
                  setState(() {
                    savedSuggestions.remove(pair);
                  });

                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text("${pair.asPascalCase} removed")));
                },
                child: ListTile(
                  title: Text(
                    pair.asPascalCase,
                    style: biggerFont,
                  ),
                ),
              );
            });
          },
        );
        final divided = ListTile.divideTiles(
          context: context,
          tiles: tiles,
        ).toList();

        return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(icon: Icon(Icons.menu), onPressed: _pushSaved),
      ),
      body: RandomWords(savedSuggestions: savedSuggestions),
    );
  }
}

class RandomWords extends StatefulWidget {
  RandomWords({Key key, this.savedSuggestions}) : super(key: key);

  final List<WordPair> savedSuggestions;

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }

        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final isSaved = widget.savedSuggestions.contains(pair);

    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: biggerFont,
      ),
      trailing: Icon(
        isSaved ? Icons.favorite : Icons.favorite_border,
        color: isSaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (isSaved) {
            widget.savedSuggestions.remove(pair);
          } else {
            widget.savedSuggestions.add(pair);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildSuggestions();
  }
}
