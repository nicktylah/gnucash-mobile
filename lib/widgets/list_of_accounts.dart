import 'package:flutter/material.dart';
import 'package:gnucash_mobile/providers/accounts.dart';
import 'package:gnucash_mobile/widgets/transactions_view.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import 'account_view.dart';

class ListOfAccounts extends StatelessWidget {
  final List<Account> accounts;
  
  ListOfAccounts({Key key, @required this.accounts}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    final _accountsBuilder = ListView.builder(
      itemBuilder: (context, index) {
        if (index.isOdd) {
          return Divider();
        }

        final int i = index ~/ 2;
        if (i >= this.accounts.length) {
          return null;
        }

        final _account = this.accounts[i];

        return ListTile(
          title: Text(
            _account.name,
            style: Constants.biggerFont,
          ),
          trailing: _account.placeholder
              ? null
              : Text(
            NumberFormat.simpleCurrency(decimalDigits: 2)
                .format(_account.balance),
          ),
          onTap: () {
            if (_account.children.length == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: Text(_account.fullName),
                    ),
                    body: TransactionsView(
                      account: _account,
                    ),
                    floatingActionButton: Builder(builder: (context) {
                      return FloatingActionButton(
                        backgroundColor: Constants.darkBG,
                        child: Icon(Icons.add),
                        onPressed: () {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "You tapped the transactions-only button!")));
                        },
                      );
                    }),
                  );
                }),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountView(account: _account),
                ),
              );
            }
          },
        );
      },
      padding: EdgeInsets.all(16.0),
      shrinkWrap: true,
    );

    return Container(
      child: _accountsBuilder,
    );
  }
}
