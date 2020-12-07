import 'dart:collection';

import 'package:flutter/foundation.dart';

class Account {
  double balance = 0.0; // non-standard
  List<Account> children = []; // non-standard
  String code;
  String commodityM;
  String commodityN;
  String color;
  String description;
  String fullName;
  bool hidden;
  String notes;
  Account parent; // non-standard
  String parentFullName; // non-standard
  bool placeholder; // Whether transactions can be placed in this account?
  bool tax;
  String type;
  String name;

  Account(String fullName) {
    this.balance = 0.0;
    this.fullName = fullName;
  }

  Account.a(
    double balance,
    String fullName,
    List<Account> children,
    Account parent,
  ) {
    this.balance = balance;
    this.children = children;
    this.fullName = fullName;
    this.parent = parent;
  }

  Account.fromList(List<String> items) {
    final trimmed = [];
    for (var item in items) trimmed.add(item.trim());

    this.type = trimmed[0];
    this.fullName = trimmed[1];
    this.name = trimmed[2];
    this.code = trimmed[3];
    this.description = trimmed[4];
    this.color = trimmed[5];
    this.notes = trimmed[6];
    this.commodityM = trimmed[7];
    this.commodityN = trimmed[8];
    this.hidden = trimmed[9] == 'T' ? true : false;
    this.tax = trimmed[10] == 'T' ? true : false;
    this.placeholder = trimmed[11] == 'T' ? true : false;
  }

  @override
  toString() {
    return "Account{balance: ${this.balance}, children: List<Account>[${this.children.length}], code: ${this.code}, commodityM: ${this.commodityM}, commodityN: ${this.commodityN}, color: ${this.color}, description: ${this.description}, fullName: ${this.fullName}, hidden: ${this.hidden}, notes: ${this.notes}, parent: ${this.parent == null ? "null" : "Account(${this.parentFullName})"}, parentFullName: ${this.parentFullName}, placeholder: ${this.placeholder}, tax: ${this.tax}, type: ${this.type}, name: ${this.name}}";
  }
}

class AccountsModel extends ChangeNotifier {
  List<Account> _accounts = [];

  final Account _favoriteCreditAccount = null;
  final Account _favoriteDebitAccount = null;
  final List<Account> _recentCreditAccounts = [];
  final List<Account> _recentDebitAccounts = [];

  UnmodifiableListView<Account> get accounts => UnmodifiableListView(_accounts);
  UnmodifiableListView<Account> get recentCreditAccounts =>
      UnmodifiableListView(_recentCreditAccounts);
  UnmodifiableListView<Account> get recentDebitAccounts =>
      UnmodifiableListView(_recentDebitAccounts);

  static List<Account> parseAccountCSV(String csv) {
    final lines = csv.trim().split("\n");

    // Remove header row
    lines.removeAt(0);
    var _accounts = <Account>[];
    for (var line in lines) {
      final _account = Account.fromList(line.split(","));
      final _lastIndex = _account.fullName.lastIndexOf(":");
      final _hasParent = _lastIndex > 0;
      var _parentFullName = '';
      if (_hasParent) {
        _parentFullName = _account.fullName.substring(0, _lastIndex);
      }
      _account.parentFullName = _parentFullName;

      _accounts.add(_account);
    }

    return _buildAccountsTree(_accounts);
  }

  static List<Account> _buildAccountsTree(List<Account> accounts) {
    final _lookup = Map<String, Account>();
    final List<Account> _hierarchicalAccounts = [];

    for (var _account in accounts) {
      if (_lookup.containsKey(_account.parentFullName)) {
        final _parent = _lookup[_account.parentFullName];
        _account.parent = _parent;
        _parent.children.add(_account);
      } else {
        _hierarchicalAccounts.add(_account);
      }

      _lookup[_account.fullName] = _account;
    }

    return _hierarchicalAccounts;
  }

  void add(Account account) {
    _accounts.add(account);
    notifyListeners();
  }

  // Test function to simulate adding bunch o' accounts
  void addAll() {
    final exampleCSV = """
  type,full_name,name,code,description,color,notes,commoditym,commodityn,hidden,tax,placeholder
  ASSET,Assets,Assets,,Assets,,,USD,CURRENCY,F,F,T
  ASSET,Assets:Current Assets,Current Assets,,Current Assets,,,USD,CURRENCY,F,F,T
  CASH,Assets:Current Assets:Cash in Wallet,Cash in Wallet,,Cash in Wallet,,,USD,CURRENCY,F,F,F
  ASSET,Assets:Current Assets:Joint Checking Account,Joint Checking Account,,Joint Checking Account,,,USD,CURRENCY,F,F,F
  ASSET,Assets:Current Assets:Venmo,Venmo,,Venmo Balance,,,USD,CURRENCY,F,F,F
  ASSET,Assets:Current Assets:Wells Fargo Checking Account,Wells Fargo Checking Account,,Lame ol' duck,,,USD,CURRENCY,F,F,F
  BANK,Assets:Current Assets:Checking Account,Checking Account,,Checking Account,,,USD,CURRENCY,F,F,F
  BANK,Assets:Current Assets:Savings Account,Savings Account,,Savings Account,,,USD,CURRENCY,F,F,F
  """;
    final _parsedAccounts = parseAccountCSV(exampleCSV);
    _accounts = _parsedAccounts;
    notifyListeners();
  }

  void removeAll() {
    _accounts.clear();
    notifyListeners();
  }
}
