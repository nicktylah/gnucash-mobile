import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:gnucash_mobile/providers/accounts.dart';
import 'package:gnucash_mobile/providers/transactions.dart';
import 'package:gnucash_mobile/widgets/export.dart';
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

                  ScaffoldMessenger.of(context).showSnackBar(
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
                title: Text('Import Accounts'),
                onTap: () {
                  if (_hasImported) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "Accounts already imported. Please remove them first."),
                    ));
                  } else {
                    Provider.of<AccountsModel>(context, listen: false).addAll();
                  }
                  Navigator.pop(context);
                }),
            ListTile(
                title: Text('Export'),
                onTap: () async {
                  // TODO: Go to export screen with at least a "delete after export" checkbox
                  final _success = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Export(),
                    ),
                  );

                  if (_success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Transactions exported!")));
                  }

                  // final _transactionsList =
                  //     Provider.of<TransactionsModel>(context, listen: false)
                  //         .transactions
                  //         .map((_transaction) => _transaction.toList())
                  //         .toList();
                  // final _csvString =
                  //     const ListToCsvConverter().convert(_transactionsList);
                  // print(_csvString);
                  //
                  // // Should things be deleted if export is successful?
                  //
                  // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //   content: Text("You're trying to export stuff!"),
                  // ));
                  // Navigator.pop(context);
                }),
            ListTile(
                title: Text('Favorites'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("You're trying to set some favorites!"),
                  ));
                  Navigator.pop(context);
                }),
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
            ? Builder(builder: (context) {
                return FloatingActionButton(
                  backgroundColor: Constants.darkBG,
                  child: Icon(Icons.add),
                  onPressed: () async {
                    final _success = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionForm(),
                      ),
                    );

                    if (_success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Transaction created!")));
                    }
                  },
                );
              })
            : null,
      );
    });
  }
}
