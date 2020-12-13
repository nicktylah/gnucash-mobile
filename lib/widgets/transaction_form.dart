import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gnucash_mobile/providers/accounts.dart';
import 'package:input_calculator/input_calculator.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class TransactionForm extends StatefulWidget {
  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  FocusNode amountFocusNode;

  @override
  void initState() {
    super.initState();

    amountFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    amountFocusNode.dispose();

    super.dispose();
  }

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountsModel>(builder: (context, accounts, child) {
      return Scaffold(
        appBar: AppBar(
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
              TextFormField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Amount',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) {
                  print("Saved $value");
                },
                validator: (value) {
                  if (value.isEmpty || double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }

                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Description',
                ),
                onSaved: (value) {
                  print("Saved $value");
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a valid description';
                  }
                  return null;
                },
              ),
              Padding(
                // padding: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                // child: ElevatedButton(
                //   onPressed: () {
                //     // Validate will return true if the form is valid, or false if
                //     // the form is invalid.
                //     if (_key.currentState.validate()) {
                //       // Process data.
                //       _key.currentState.save();
                //       print(_key.currentState.toString());
                //     } else {
                //       print("invalid form");
                //     }
                //   },
                //   child: Text('Save'),
                // ),
              ),
            ],
          ),
          key: _key,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Constants.darkBG,
          child: Icon(Icons.save_sharp),
          onPressed: () {
            // Validate will return true if the form is valid, or false if
            // the form is invalid.
            if (_key.currentState.validate()) {
              // Process data.
              _key.currentState.save();
              print(_key.currentState.toString());
            } else {
              print("invalid form");
            }
          },
        ),
      );
    });
  }
}
