import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gnucash_mobile/providers/accounts.dart';
import 'package:gnucash_mobile/providers/transactions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class TransactionForm extends StatefulWidget {
  final Account toAccount;
  final String transactionID;

  TransactionForm(
      {Key key, this.toAccount, this.transactionID})
      : super(key: key);
  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  @override
  void initState() async {
    super.initState();
    _dateInputController.text = DateFormat.yMd().format(DateTime.now());
    this._transactions = [Transaction(), Transaction()];
    if (widget.transactionID != "") {
      final _existingTransactions = await Provider.of<TransactionsModel>(context, listen: false)
          .get(widget.transactionID);
      if (_existingTransactions.length == 2) {
        this._transactions = _existingTransactions;
      }
    }
  }

  final _key = GlobalKey<FormState>();
  final _visibleAmountInputController = TextEditingController();
  final _dateInputController = TextEditingController();
  var _transactions;

  @override
  void dispose() {
    _visibleAmountInputController.dispose();
    _dateInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _node = FocusScope.of(context);
    final _simpleCurrencyNumberFormat = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

    return Consumer<AccountsModel>(builder: (context, accounts, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.darkBG,
          title: Text("New transaction"),
          leading: Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => Navigator.pop(context),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            );
          }),
        ),
        body: Form(
          autovalidateMode: AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              Focus(
                child: TextFormField(
                  autofocus: true,
                  controller: _visibleAmountInputController,
                  decoration: const InputDecoration(
                    hintText: 'Amount',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onEditingComplete: () => _node.nextFocus(),
                  onSaved: (value) {
                    final _amount = _simpleCurrencyNumberFormat.parse(value);
                    _transactions[0].amount = _amount;
                    _transactions[0].amountWithSymbol = value;
                    _transactions[1].amount = -_amount;
                    _transactions[1].amountWithSymbol = "-" + value;
                  },
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a valid amount';
                    }

                    return null;
                  },
                ),
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    final _rawValue = _visibleAmountInputController.value.text;
                    final _simpleCurrencyValue = _simpleCurrencyNumberFormat
                        .format(_simpleCurrencyNumberFormat.parse(_rawValue));
                    _visibleAmountInputController.value =
                        _visibleAmountInputController.value.copyWith(
                      text: _simpleCurrencyValue,
                    );
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Description',
                ),
                onEditingComplete: () => _node.nextFocus(),
                onSaved: (value) {
                  _transactions[0].description = value;
                  _transactions[1].description = value;
                },
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a valid description';
                  }
                  return null;
                },
              ),
              FutureBuilder<Account>(
                  future: Provider.of<AccountsModel>(context, listen: false)
                      .favoriteCreditAccount,
                  builder: (context, AsyncSnapshot<Account> snapshot) {
                    return DropdownButtonFormField<Account>(
                        decoration: const InputDecoration(
                          hintText: 'Credit Account',
                        ),
                        isExpanded: true,
                        // TODO: Put recently used first
                        items: accounts.validTransactionAccounts.map((account) {
                          return DropdownMenuItem(
                            value: account,
                            child: Text(
                              account.fullName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {},
                        onSaved: (value) {
                          _transactions[0].fullAccountName = value.fullName;
                          _transactions[0].accountName = value.name;
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please enter a valid account to credit.';
                          }
                          return null;
                        },
                        value: snapshot.hasData
                            ? accounts.validTransactionAccounts.firstWhere(
                                (account) =>
                                    account.fullName == snapshot.data.fullName)
                            : widget.toAccount != null
                                ? accounts.validTransactionAccounts.firstWhere(
                                    (account) =>
                                        account.fullName ==
                                        widget.toAccount.fullName)
                                : null);
                  }),
              FutureBuilder<Account>(
                  future: Provider.of<AccountsModel>(context, listen: false)
                      .favoriteDebitAccount,
                  builder: (context, AsyncSnapshot<Account> snapshot) {
                    return DropdownButtonFormField<Account>(
                      decoration: const InputDecoration(
                        hintText: 'Debit Account',
                      ),
                      isExpanded: true,
                      // TODO: put recently used first
                      items: accounts.validTransactionAccounts.map((account) {
                        return DropdownMenuItem(
                          value: account,
                          child: Text(account.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {},
                      onSaved: (value) {
                        _transactions[1].fullAccountName = value.fullName;
                        _transactions[1].accountName = value.name;
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please enter a valid account to debit';
                        }
                        return null;
                      },
                      value: snapshot.hasData
                          ? accounts.validTransactionAccounts.firstWhere(
                              (account) =>
                                  account.fullName == snapshot.data.fullName)
                          : null,
                    );
                  }),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Date',
                ),
                controller: _dateInputController,
                onSaved: (value) {
                  _transactions[0].date = DateFormat('yyyy-MM-dd')
                      .format(DateFormat.yMd().parse(value));
                },
                onTap: () async {
                  final _now = DateTime.now();
                  final _date = await showDatePicker(
                    context: context,
                    initialDate: _now,
                    firstDate: DateTime(_now.year - 10),
                    lastDate: DateTime(_now.year + 10),
                  );

                  _dateInputController.text = DateFormat.yMd().format(_date);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a valid date';
                  }
                  try {
                    DateFormat.yMd().parse(value);
                  } catch (FormatException) {
                    return 'Please enter a valid date';
                  }

                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Notes',
                ),
                textCapitalization: TextCapitalization.sentences,
                onSaved: (value) {
                  _transactions[0].notes = value;
                },
              ),
            ],
          ),
          key: _key,
        ),
        floatingActionButton:
            // Builder(builder: (context) {
            FloatingActionButton(
          backgroundColor: Constants.darkBG,
          child: Icon(Icons.save_sharp),
          onPressed: () {
            // Validate will return true if the form is valid, or false if
            // the form is invalid.
            if (_key.currentState.validate()) {
              // Process data.
              _key.currentState.save();

              final id = UniqueKey().toString();
              _transactions[0].id = id;
              _transactions[1].id = id;

              Provider.of<TransactionsModel>(context, listen: false)
                  .addAll(_transactions);
              Navigator.pop(context, true);
            } else {
              print("invalid form");
            }
          },
        ),
      );
    });
  }
}
