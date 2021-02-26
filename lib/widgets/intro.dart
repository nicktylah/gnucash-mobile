import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gnucash_mobile/constants.dart';
import 'package:gnucash_mobile/providers/accounts.dart';
import 'package:provider/provider.dart';

class Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(Constants.darkAccent),
        ),
        onPressed: () async {
          FilePickerResult result = await FilePicker.platform.pickFiles();

          if (result != null) {
            try {
              final _file = File(result.files.single.path);
              String contents = await _file.readAsString();
              Provider.of<AccountsModel>(context, listen: false)
                  .addAll(contents);
            } catch (e) {
              print(e);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    "Oops, something went wrong while importing. Please correct any errors in your Accounts CSV and try again."),
              ));
            }
          }
        },
        child: Text(
          "Import",
          style: TextStyle(
            color: Constants.lightPrimary,
          ),
        ),
      ),
    );
  }
}
