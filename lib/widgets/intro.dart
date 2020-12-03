import 'package:flutter/material.dart';
import 'package:gnucash_mobile/constants.dart';
import 'package:gnucash_mobile/providers/accounts.dart';
import 'package:provider/provider.dart';

class Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlatButton(
        child: Text('Import Accounts'),
        color: Constants.darkAccent,
        onPressed: () =>
            Provider.of<AccountsModel>(context, listen: false).addAll(),
        textColor: Constants.lightPrimary,
      ),
    );
  }
}
