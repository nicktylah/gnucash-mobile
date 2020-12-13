import 'package:flutter/material.dart';
import 'package:gnucash_mobile/providers/accounts.dart';
import 'package:gnucash_mobile/providers/transactions.dart';
import 'package:gnucash_mobile/widgets/intro.dart';
import 'package:gnucash_mobile/widgets/list_of_accounts.dart';
import 'package:gnucash_mobile/widgets/transaction_form.dart';
import 'package:provider/provider.dart';
import 'constants.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AccountsModel()),
      ChangeNotifierProvider(create: (context) => TransactionsModel()),
    ],
    child: MyApp(),
  ));
}

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
                key: Key(account.fullName),
                onDismissed: (direction) {
                  setState(() {
                    savedAccounts.remove(account);
                  });

                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text("${account.fullName} removed")));
                },
                child: ListTile(
                  title: Text(
                    account.fullName,
                    style: Constants.biggerFont,
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
      final _hasImported = accounts.accounts.length > 0;

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: _hasImported
            ? ListOfAccounts(accounts: accounts.accounts)
            : Intro(),
        drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Constants.darkBG,
                  ),
                ),
                ListTile(
                    title: Text('Delete Accounts'),
                    onTap: () {
                      Provider.of<AccountsModel>(context, listen: false)
                          .removeAll();
                      Navigator.pop(context);
                    }),
              ],
            )),
        floatingActionButton: _hasImported
            ? FloatingActionButton(
          backgroundColor: Constants.darkBG,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionForm(),
              ),
            );
          },
        )
            : null,
      );
    });
  }
}
