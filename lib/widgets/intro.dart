
import 'package:flutter/material.dart';
import 'package:gnucash_mobile/providers/accounts.dart';
import 'package:provider/provider.dart';

class Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
        child: Text('Import Accounts'),
          onPressed: () => Provider.of<AccountsModel>(context, listen: false).addAll(),
      ),
    );
  }
}
