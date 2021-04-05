import 'package:flutter/material.dart';
import 'package:gnucash_mobile/providers/accounts.dart';
import 'package:gnucash_mobile/providers/transactions.dart';
import 'package:gnucash_mobile/widgets/list_of_accounts.dart';
import 'package:gnucash_mobile/widgets/transaction_form.dart';
import 'package:gnucash_mobile/widgets/transactions_view.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class AccountView extends StatelessWidget {
  final Account account;

  AccountView({Key key, @required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Deliver simpler view if this account cannot hold transactions
    if (this.account.placeholder) {
      return Scaffold(
        appBar: AppBar(
          title: Text(this.account.fullName),
        ),
        body: ListOfAccounts(accounts: this.account.children),
        floatingActionButton: Builder(builder: (context) {
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
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Transaction created!")));
              }
            },
          );
        }),
      );
    }

    // Deliver a tabbed view with both sub-accounts and transactions
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
            ListOfAccounts(accounts: this.account.children),
            TransactionsView(
                transactions: Provider.of<TransactionsModel>(context,
                            listen: true)
                        .transactionsByAccountFullName[this.account.fullName] ??
                    [])
          ],
        ),
        floatingActionButton: Builder(builder: (context) {
          return FloatingActionButton(
            backgroundColor: Constants.darkBG,
            child: Icon(Icons.add),
            onPressed: () async {
              final _success = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionForm(
                    toAccount: this.account,
                  ),
                ),
              );

              if (_success != null && _success) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Transaction created!")));
              }
            },
          );
        }),
      ),
    );
  }
}
