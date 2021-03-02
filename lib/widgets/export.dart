import 'dart:io';

// The commented code in this file is for choosing a directory to export to.
// This works on Android, but on iOS we can't write a file to external storage.
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gnucash_mobile/providers/transactions.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class Export extends StatefulWidget {
  @override
  _ExportState createState() => _ExportState();
}

class _ExportState extends State<Export> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // String _fileName;
  // List<PlatformFile> _paths;
  // String _directoryPath;
  // String _folder;
  // String _extension;
  // bool _loadingPath = false;
  // bool _multiPick = false;
  // FileType _pickingType = FileType.any;
  // TextEditingController _controller = TextEditingController();

  bool deleteTransactionsOnExport = false;
  String exportDirectory;

  @override
  void initState() {
    getApplicationDocumentsDirectory().then((value) {
      exportDirectory = value.path;
    });

    super.initState();
  }

  // void _selectFolder() {
  //   FilePicker.platform.getDirectoryPath().then((value) {
  //     if (value == null) return;
  //     setState(() {
  //       _directoryPath = value;
  //       _folder = value.substring(value.lastIndexOf("/"));
  //     });
  //   });
  // }

  Future<String> _getAndFormatTransactions() async {
    final _transactions =
        await Provider.of<TransactionsModel>(context, listen: false)
            .readTransactionsCsv();

    return _transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Export Transactions"),
      ),
      body: Center(
        child: FutureBuilder(
            future: Provider.of<TransactionsModel>(context, listen: false)
                .readTransactionsCsv(),
            builder: (context, AsyncSnapshot<String> snapshot) {
              String _text;
              if (snapshot.hasData) {
                // Remove 1 for header row, divide by 2 for double entry
                final _numTransactions =
                    ("\n".allMatches(snapshot.data).length - 1) / 2;
                _text = "${_numTransactions.toInt()} transaction(s)";
              } else {
                _text = "0 transactions";
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      "$_text will be written to $exportDirectory",
                    ),
                  ),
                  // Text(
                  //   "Export to: $_folder"
                  // ),
                  // FlatButton(
                  //   color: Constants.darkAccent,
                  //   onPressed: () => _selectFolder(),
                  //   child: Text("Pick folder"),
                  //   textColor: Constants.lightPrimary,
                  // ),
                  CheckboxListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                    title: Text('Delete transactions on successful export'),
                    value: deleteTransactionsOnExport,
                    onChanged: (value) {
                      setState(() {
                        deleteTransactionsOnExport = value;
                      });
                    },
                  ),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Constants.darkAccent),
                    ),
                    onPressed: () async {
                      // if (_directoryPath == null) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(content: Text("Please choose a valid directory")));
                      //   return null;
                      // }

                      if (!snapshot.hasData) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("No transactions to export.")));
                        return;
                      }

                      final _yearMonthDay =
                          DateFormat('yyyyMMdd').format(DateTime.now());
                      try {
                        final _fileName =
                            "$exportDirectory/${_yearMonthDay}_${DateTime.now().millisecond}.gnucash_transactions.csv";
                        await File(_fileName).writeAsString(snapshot.data);

                        if (deleteTransactionsOnExport) {
                          Provider.of<TransactionsModel>(context, listen: false)
                              .removeAll();
                        }

                        Navigator.pop(context, true);
                      } catch (e) {
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error exporting!")));
                      }
                    },
                    child: Text(
                      "Export",
                      style: TextStyle(
                        color: Constants.lightPrimary,
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
