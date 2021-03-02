import 'package:flutter/material.dart';
import 'package:gnucash_mobile/providers/accounts.dart';
import 'package:gnucash_mobile/providers/transactions.dart';
import 'package:gnucash_mobile/widgets/transactions_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import 'account_view.dart';

class ListOfAccounts extends StatelessWidget {
  final List<Account> accounts;

  ListOfAccounts({Key key, @required this.accounts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<TransactionsModel>(
          builder: (context, transactionsModel, child) {
        return ListView.builder(
          itemBuilder: (context, index) {
            if (index.isOdd) {
              return Divider();
            }

            final int i = index ~/ 2;
            if (i >= this.accounts.length) {
              return null;
            }

            final _account = this.accounts[i];
            final List<Transaction> _transactions = [];
            for (var key in transactionsModel.transactionsByAccountFullName.keys) {
              if (key.startsWith(_account.fullName)) {
                _transactions.addAll(transactionsModel.transactionsByAccountFullName[key]);
              }
            }
            final double _balance = _transactions.fold(0.0,
                (previousValue, element) => previousValue + element.amount);

            return ListTile(
              title: Text(
                _account.name,
                style: Constants.biggerFont,
              ),
              trailing: Text(
                NumberFormat.simpleCurrency(decimalDigits: 2).format(_balance),
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
                          transactions: _transactions,
                        ),
                        floatingActionButton: Builder(builder: (context) {
                          return FloatingActionButton(
                            backgroundColor: Constants.darkBG,
                            child: Icon(Icons.add),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
      }),
    );
  }
}
