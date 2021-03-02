import 'package:flutter/material.dart';
import 'package:gnucash_mobile/providers/transactions.dart';
import 'package:provider/provider.dart';

class TransactionsView extends StatelessWidget {
  final List<Transaction> transactions;

  TransactionsView({Key key, @required this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionsModel>(builder: (context, transactions, child) {
      final _transactionsBuilder = ListView.builder(
        itemBuilder: (context, index) {
          if (index.isOdd) {
            return Divider();
          }

          final int i = index ~/ 2;
          if (i >= this.transactions.length) {
            return null;
          }

          final _transaction = this.transactions[i];
          return ListTile(
              title: Text(
                _transaction.description,
              ),
              trailing: Text(_transaction.amountWithSymbol),
              onTap: () {
                print(_transaction);
              });
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
