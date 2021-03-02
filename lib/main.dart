import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gnucash_mobile/providers/accounts.dart';
import 'package:gnucash_mobile/providers/transactions.dart';
import 'package:gnucash_mobile/widgets/export.dart';
import 'package:gnucash_mobile/widgets/favorites.dart';
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

  // void _pushSaved() {
  //   Navigator.of(context).push(
  //     MaterialPageRoute<void>(builder: (BuildContext context) {
  //       final tiles = savedAccounts.map(
  //         (Account account) {
  //           return new Builder(builder: (context) {
  //             return Dismissible(
  //               background: Container(color: Colors.red),
  //               key: Key(account.fullName),
  //               onDismissed: (direction) {
  //                 setState(() {
  //                   savedAccounts.remove(account);
  //                 });
  //
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(content: Text("${account.fullName} removed")));
  //               },
  //               child: ListTile(
  //                 title: Text(
  //                   account.fullName,
  //                   style: Constants.biggerFont,
  //                 ),
  //               ),
  //             );
  //           });
  //         },
  //       );
  //       final divided = ListTile.divideTiles(
  //         context: context,
  //         tiles: tiles,
  //       ).toList();
  //
  //       return Scaffold(
  //           appBar: AppBar(
  //             title: Text('Saved Accounts'),
  //           ),
  //           body: ListView(children: divided));
  //     }),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountsModel>(builder: (context, accountsModel, child) {
      return FutureBuilder<List<Account>>(
          future: Provider.of<AccountsModel>(context, listen: false).accounts,
          builder: (context, AsyncSnapshot<List<Account>> snapshot) {
            final accounts = snapshot.hasData ? snapshot.data : [];
            final _hasImported = accounts.length > 0;

            return Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
              ),
              body: _hasImported ? ListOfAccounts(accounts: accounts) : Intro(),
              drawer: Drawer(
                  child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Text(
                      "Gnucash Mobile",
                      style: TextStyle(
                        color: Constants.lightPrimary,
                        fontSize: 20,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Constants.darkBG,
                    ),
                  ),
                  ListTile(
                      title: Text('Import Accounts'),
                      onTap: () async {
                        if (_hasImported) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Accounts already imported. Please remove them first."),
                          ));
                          Navigator.pop(context);
                          return;
                        }

                        FilePickerResult result =
                            await FilePicker.platform.pickFiles();

                        if (result != null) {
                          try {
                            final _file = File(result.files.single.path);
                            String contents = await _file.readAsString();
                            Provider.of<AccountsModel>(context, listen: false)
                                .addAll(contents);
                            Navigator.pop(context);
                          } catch (e) {
                            print(e);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Oops, something went wrong while importing. Please correct any errors in your Accounts CSV and try again."),
                            ));
                          }
                        }
                      }),
                  ListTile(
                      title: Text('Export'),
                      onTap: () async {
                        final _success = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Export(),
                          ),
                        );

                        if (_success != null && _success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Transactions exported!")));
                        }
                      }),
                  ListTile(
                      title: Text('Favorites'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Favorites(),
                          ),
                        );
                      }),
                  ListTile(
                      title: Text('Delete Accounts'),
                      onTap: () {
                        Provider.of<AccountsModel>(context, listen: false)
                            .removeAll();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Accounts deleted.")));
                      }),
                  ListTile(
                      title: Text('Delete Transactions'),
                      onTap: () {
                        Provider.of<TransactionsModel>(context, listen: false)
                            .removeAll();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Transactions deleted.")));
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

                          if (_success != null && _success) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Transaction created!")));
                          }
                        },
                      );
                    })
                  : null,
            );
          });
    });
  }
}
