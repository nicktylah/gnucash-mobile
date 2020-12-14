import 'dart:collection';

import 'package:flutter/foundation.dart';

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
  bool reconcile = false;
  DateTime reconcileDate;
  int ratePrice;

  Transaction.fromList(List<dynamic> items) {
    final trimmed = [];
    for (var item in items) trimmed.add(item.trim());

    this.date = trimmed[0];
    this.id = trimmed[1];
    this.number = int.parse(trimmed[2]);
    this.description = trimmed[3];
    this.notes = trimmed[4];
    this.commodityCurrency = trimmed[5];
    this.voidReason = trimmed[6];
    this.action = trimmed[7];
    this.memo = trimmed[8];
    this.fullAccountName = trimmed[9];
    this.accountName = trimmed[10];
    this.amountWithSymbol = trimmed[11];
    this.amount = double.parse(trimmed[12]);
    this.reconcile = trimmed[13] == 'n' ? false : true;
    this.reconcileDate = DateTime.parse(trimmed[14]);
    this.ratePrice = int.parse(trimmed[15]);
  }

  Transaction();

  @override
  toString() {
    return """Transaction{date: ${this.date}, id: ${this.id}, number: ${this.number}, description: ${this.description}, notes: ${this.notes}, commodityCurrency: ${this.commodityCurrency}, voidReason: ${this.voidReason}, action: ${this.action}, memo: ${this.memo}, fullAccountName: ${this.fullAccountName}, accountName: ${this.accountName}, amountWithSymbol: ${this.amountWithSymbol}, amount: ${this.amount}, reconcile: ${this.reconcile}, reconcileDate: ${this.reconcileDate}, ratePrice: ${this.ratePrice}}""";
  }
}

class TransactionsModel extends ChangeNotifier {
  final _fakeTransactions = [

  ];

  List<Transaction> _transactions = [];
  // Map<String, List<Transaction>> _transactionsByAccountFullName = Map();
  Map<String, List<Transaction>> _transactionsByAccountFullName = {
    "Expenses:Food:Delivery": [Transaction.fromList([
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
    ])],
    "Expenses:Food": [Transaction.fromList([
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
    ])]
  };

  UnmodifiableListView<Transaction> get transactions => UnmodifiableListView(_transactions);
  UnmodifiableMapView<String, List<Transaction>> get transactionsByAccountFullName => UnmodifiableMapView(_transactionsByAccountFullName);

  void add(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void addAll(List<Transaction> transactions) {
    _transactions.addAll(transactions);
    notifyListeners();
  }

  void removeAll() {
    _transactions.clear();
    notifyListeners();
  }
}
