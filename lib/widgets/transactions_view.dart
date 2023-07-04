import 'package:flutter/material.dart';
import 'package:gnucash_mobile/providers/transactions.dart';
import 'package:gnucash_mobile/widgets/transaction_form.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionsView extends StatelessWidget {
  final List<Transaction> transactions;

  TransactionsView({Key key, @required this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _simpleCurrencyNumberFormat = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

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
          final _simpleCurrencyValue = _simpleCurrencyNumberFormat.format(
              _simpleCurrencyNumberFormat
                  .parse(_transaction.amount.toString()));
          return Dismissible(
            background: Container(color: Colors.red),
            key: Key(_transaction.description + _transaction.fullAccountName),
            onDismissed: (direction) async {
              transactions.remove(_transaction.id);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Transaction removed.")));
            },
            child: ListTile(
                title: Text(
                  _transaction.description,
                ),
                trailing: Text(_simpleCurrencyValue),
                onTap: () async {
                  print(_transaction);
                  final _success = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionForm(),
                    ),
                  );
                }),
          );
        },
        padding: EdgeInsets.all(16.0),
        shrinkWrap: true,
      );

      return Container(
        child: this.transactions.length > 0
            ? _transactionsBuilder
            : Center(child: Text("No transactions.")),
      );
    });
  }
}
