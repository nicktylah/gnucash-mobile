import 'package:flutter/material.dart';
import 'package:gnucash_mobile/providers/accounts.dart';
import 'package:gnucash_mobile/widgets/intro.dart';
import 'package:intl/intl.dart';
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
        body: accounts.accounts.length > 0
            ? ParentAccountsList(
                accounts: accounts,
                savedAccounts: savedAccounts,
              )
            : Intro(),
      );
    });
  }
}

class ParentAccountsList extends StatefulWidget {
  ParentAccountsList({Key key, this.savedAccounts, this.accounts})
      : super(key: key);

  final AccountsModel accounts;
  final List<Account> savedAccounts;

  @override
  _ParentAccountsListState createState() => _ParentAccountsListState();
}

class _ParentAccountsListState extends State<ParentAccountsList> {
  @override
  Widget build(BuildContext context) {
    final builderTest = ListView.builder(
      itemCount: widget.accounts.accounts.length,
      itemBuilder: (context, index) {
        final _account = widget.accounts.accounts[index];
        return ListTile(
          title: Text(
            _account.name,
            style: biggerFont,
          ),
          trailing: _account.placeholder
              ? null
              : Text(
                  NumberFormat.simpleCurrency(decimalDigits: 2)
                      .format(_account.balance),
                ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccountView(account: _account),
              ),
            );
          },
        );
      },
      padding: EdgeInsets.all(16.0),
      shrinkWrap: true,
    );

    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            builderTest,
            FlatButton(
              color: Constants.darkAccent,
              child: Text('Remove Accounts'),
              onPressed: () =>
                  Provider.of<AccountsModel>(context, listen: false)
                      .removeAll(),
              textColor: Constants.lightPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class AccountView extends StatelessWidget {
  final Account account;

  AccountView({Key key, @required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _builderTest = ListView.builder(
      // itemCount: this.account.children.length,
      itemBuilder: (context, index) {
        if (index.isOdd) {
          return Divider();
        }

        final int i = index ~/ 2;
        if (i >= this.account.children.length) {
          return null;
        }

        final _childAccount = this.account.children[i];
        return ListTile(
          title: Text(
            _childAccount.name,
            style: biggerFont,
          ),
          trailing: _childAccount.placeholder
              ? null
              : Text(
                  NumberFormat.simpleCurrency(decimalDigits: 2)
                      .format(_childAccount.balance),
                ),
          onTap: () {
            if (_childAccount.children.length == 0) {
              // Take them to Transactions view here
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccountView(account: _childAccount),
              ),
            );
          },
        );
      },
      padding: EdgeInsets.all(16.0),
      shrinkWrap: true,
    );

    // Simpler view if this account cannot hold transactions
    if (this.account.placeholder) {
      return Scaffold(
        appBar: AppBar(
          title: Text(this.account.fullName),
        ),
        body: _builderTest,
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.account_tree_sharp)),
              Tab(icon: Icon(Icons.account_balance_sharp)),
            ],
          ),
          title: Text(this.account.fullName),
        ),
        body: TabBarView(
          children: [
            _builderTest,
            Icon(Icons.account_balance_sharp),
          ],
        ),
      ),
    );
  }
}
