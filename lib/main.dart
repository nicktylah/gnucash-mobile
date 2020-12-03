import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:gnucash_mobile/providers/accounts.dart';
import 'package:gnucash_mobile/widgets/intro.dart';
import 'package:provider/provider.dart';
import 'constants.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AccountsModel()),
    ],
    child: MyApp(),
  ));
}

const biggerFont = TextStyle(fontSize: 18.0);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appName,
      theme: Constants.lightTheme,
      darkTheme: Constants.darkTheme,
        home: MyHomePage(title: 'Accounts'),
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
  final savedAccounts = <Account>[];

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (BuildContext context) {
        final tiles = savedAccounts.map(
          (Account account) {
            return new Builder(builder: (context) {
              return Dismissible(
                background: Container(color: Colors.red),
                key: Key(account.name),
                onDismissed: (direction) {
                  setState(() {
                    savedAccounts.remove(account);
                  });

                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text("${account.name} removed")));
                },
                child: ListTile(
                  title: Text(
                    account.name,
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
              title: Text('Saved Accounts'),
            ),
            body: ListView(children: divided));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountsModel>(builder: (context, accounts, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(icon: Icon(Icons.menu), onPressed: _pushSaved),
        ),
        body: accounts.accounts.length > 0 ? RandomWords(
          accounts: accounts,
          savedAccounts: savedAccounts,
        ) : Intro(),
      );
    });
  }
}

class RandomWords extends StatefulWidget {
  RandomWords({Key key, this.savedAccounts, this.accounts}) : super(key: key);

  final AccountsModel accounts;
  final List<Account> savedAccounts;

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountsModel>(builder: (context, accounts, child) {
      final tiles = accounts.accounts.map(
              (Account account) {
            final isSaved = widget.savedAccounts.contains(account);

            return ListTile(
              title: Text(
                account.name,
                style: biggerFont,
              ),
              trailing: Icon(
                isSaved ? Icons.favorite : Icons.favorite_border,
                color: isSaved ? Colors.red : null,
              ),
              onTap: () {
                setState(() {
                  if (isSaved) {
                    widget.savedAccounts.remove(account);
                  } else {
                    widget.savedAccounts.add(account);
                  }

                  account.children?.forEach((child) {
                    print(child.name);
                  });
                });
              },
            );
          }
      );

      final divided = ListTile
          .divideTiles(context: context, tiles: tiles)
          .toList();

      return Container(
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: divided,
          ),
      );
    });
  }
}
