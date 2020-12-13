import 'package:flutter/material.dart';
import 'package:gnucash_mobile/providers/accounts.dart';
import 'package:gnucash_mobile/providers/transactions.dart';
import 'package:provider/provider.dart';

class TransactionsView extends StatelessWidget {
  final Account account;

  TransactionsView(
      {Key key, @required this.account})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionsModel>(builder: (context, transactions, child) {

      List<Transaction> _transactionsForAccount = [];
      if (transactions.transactionsByAccountFullName
          .containsKey(this.account.fullName)) {
        _transactionsForAccount = transactions
            .transactionsByAccountFullName[this.account.fullName];
      }

      final _transactionsBuilder = ListView.builder(
        itemBuilder: (context, index) {
          if (index.isOdd) {
            return Divider();
          }

          final int i = index ~/ 2;
          if (i >= _transactionsForAccount.length) {
            return null;
          }

          final _transaction = _transactionsForAccount[i];
          return ListTile(
              title: Text(
                _transaction.description,
              ),
              trailing: Text(_transaction.amountWithSymbol),
              onTap: () {});
        },
        padding: EdgeInsets.all(16.0),
        shrinkWrap: true,
      );

      return Container(
        child: _transactionsBuilder,
      );
    });
  }
}
