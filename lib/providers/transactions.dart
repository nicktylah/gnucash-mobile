import 'dart:collection';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class Transaction {
  String date;
  String id;
  int number;
  String description;
  String notes;
  String commodityCurrency;
  String voidReason;
  String action;
  String memo;
  String fullAccountName;
  String accountName;
  String amountWithSymbol;
  double amount;
  String reconcile = "n";
  String reconcileDate;
  int ratePrice;

  Transaction.fromList(List<dynamic> items) {
    final trimmed = [];
    for (var item in items) trimmed.add(item.trim());

    this.date = trimmed[0] ?? "";
    this.id = trimmed[1];
    this.number = int.tryParse(trimmed[2]) ?? null;
    this.description = trimmed[3];
    this.notes = trimmed[4];
    this.commodityCurrency = trimmed[5];
    this.voidReason = trimmed[6];
    this.action = trimmed[7];
    this.memo = trimmed[8];
    this.fullAccountName = trimmed[9];
    this.accountName = trimmed[10];
    this.amountWithSymbol = trimmed[11];
    this.amount = double.tryParse(trimmed[12]) ?? null;
    this.reconcile = trimmed[13];
    this.reconcileDate = trimmed[14];
    this.ratePrice = int.tryParse(trimmed[15]) ?? null;
  }

  Transaction();

  @override
  toString() {
    return """Transaction{date: ${this.date}, id: ${this.id}, number: ${this.number}, description: ${this.description}, notes: ${this.notes}, commodityCurrency: ${this.commodityCurrency}, voidReason: ${this.voidReason}, action: ${this.action}, memo: ${this.memo}, fullAccountName: ${this.fullAccountName}, accountName: ${this.accountName}, amountWithSymbol: ${this.amountWithSymbol}, amount: ${this.amount}, reconcile: ${this.reconcile}, reconcileDate: ${this.reconcileDate}, ratePrice: ${this.ratePrice}}""";
  }

  List<dynamic> toList() {
    return [
      this.date ?? "",
      this.id ?? "",
      this.number ?? "",
      this.description ?? "",
      this.notes ?? "",
      this.commodityCurrency ?? "",
      this.voidReason ?? "",
      this.action ?? "",
      this.memo ?? "",
      this.fullAccountName ?? "",
      this.accountName ?? "",
      this.amountWithSymbol ?? "",
      this.amount ?? "",
      this.reconcile ?? "",
      this.reconcileDate ?? "",
      this.ratePrice ?? ""
    ];
  }
}

class TransactionsModel extends ChangeNotifier {
  Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/transactions.csv');
  }

  Future<UnmodifiableListView<Transaction>> readTransactions() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();

      var _detector = new FirstOccurrenceSettingsDetector(
        eols: ['\r\n', '\n'],
      );

      final _converter = CsvToListConverter(
        csvSettingsDetector: _detector,
        textDelimiter: '"',
        shouldParseNumbers: false,
      );

      final _parsed = _converter.convert(contents.trim());

      final _transactions = <Transaction>[];
      for (var line in _parsed) {
        final _transaction = Transaction.fromList(line);
        _transactions.add(_transaction);
      }

      return UnmodifiableListView(_transactions);
    } catch (e) {
      print("readTransactions error");
      print(e);
      return null;
    }
  }

  Future<String> readTransactionsCsv() async {
    try {
      final _file = await _localFile;
      final _string = await _file.readAsString();
      return "Date,Transaction ID,Number,Description,Notes,Commodity/Currency,Void Reason,Action,Memo,Full Account Name,Account Name,Amount With Sym.,Amount Num,Reconcile,Reconcile Date,Rate/Price\n$_string";
    } catch (e) {
      print(e);
      return null;
    }
  }

  final _fakeTransactions = [];

  List<Transaction> _transactions = [];
  // Map<String, List<Transaction>> _transactionsByAccountFullName = Map();
  Map<String, List<Transaction>> _transactionsByAccountFullName = {
    "Expenses:Food:Delivery": [
      Transaction.fromList([
        DateTime.now().toString(),
        "1",
        "1",
        "Test description",
        "Test notes",
        "USD",
        "",
        "Test action",
        "Test memo",
        "Expenses:Food",
        "Food",
        "\$10",
        "10",
        "n",
        DateTime.now().toString(),
        "2",
      ])
    ],
    "Expenses:Food": [
      Transaction.fromList([
        DateTime.now().toString(),
        "2",
        "2",
        "Test description",
        "Test notes",
        "USD",
        "",
        "Test action",
        "Test memo",
        "Expenses:Food",
        "Food",
        "\$12",
        "12",
        "n",
        DateTime.now().toString(),
        "3",
      ])
    ]
  };

  Future<UnmodifiableListView<Transaction>> get transactions {
    return readTransactions();
    // return UnmodifiableListView(_transactions);
  }

  UnmodifiableMapView<String, List<Transaction>>
      get transactionsByAccountFullName =>
          UnmodifiableMapView(_transactionsByAccountFullName);

  void add(Transaction transaction) async {
    final file = await _localFile;
    final _csvString = const ListToCsvConverter().convert(transaction.toList());

    try {
      file.writeAsString(
        "$_csvString\n",
        mode: FileMode.append,
      );
    } catch (e) {
      print(e);
    }

    // _transactions.add(transaction);
    notifyListeners();
  }

  void addAll(List<Transaction> transactions) async {
    final file = await _localFile;
    final _csvString = const ListToCsvConverter(eol: "\n")
        .convert(transactions.map((t) => t.toList()).toList());

    try {
      file.writeAsString(
        "$_csvString\n",
        mode: FileMode.append,
      );
    } catch (e) {
      print("addAll error");
      print(e);
    }

    // _transactions.addAll(transactions);
    notifyListeners();
  }

  void removeAll() async {
    final file = await _localFile;

    try {
      file.delete();
    } catch (e) {
      print(e);
    }

    // _transactions.clear();
    notifyListeners();
  }
}
