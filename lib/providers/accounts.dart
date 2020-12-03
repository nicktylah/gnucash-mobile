import 'dart:collection';

import 'package:flutter/foundation.dart';

class Account {
  double balance;
  List<Account> children;
  String code;
  String commodityM;
  String commodityN;
  String color;
  String description;
  String fullName;
  bool hidden;
  String notes;
  Account parent;
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

  // Example CSV dump from GnuCash
  // type,full_name,name,code,description,color,notes,commoditym,commodityn,hidden,tax,placeholder
  // ASSET,Assets,Assets,,Assets,,,USD,CURRENCY,F,F,T
  // ASSET,Assets:Current Assets,Current Assets,,Current Assets,,,USD,CURRENCY,F,F,T
  // CASH,Assets:Current Assets:Cash in Wallet,Cash in Wallet,,Cash in Wallet,,,USD,CURRENCY,F,F,F
  // ASSET,Assets:Current Assets:Joint Checking Account,Joint Checking Account,,Chase Checking Account w/ Hayla,,,USD,CURRENCY,F,F,F
  // ASSET,Assets:Current Assets:Venmo,Venmo,,Venmo Balance,,,USD,CURRENCY,F,F,F
  // ASSET,Assets:Current Assets:Wells Fargo Checking Account,Wells Fargo Checking Account,,Lame ol' duck,,,USD,CURRENCY,F,F,F
  // BANK,Assets:Current Assets:Checking Account,Checking Account,,Checking Account,,,USD,CURRENCY,F,F,F
  // BANK,Assets:Current Assets:Savings Account,Savings Account,,Savings Account,,,USD,CURRENCY,F,F,F

  // Test function to simulate adding bunch o' accounts
  void add(Account account) {
    _accounts.add(account);
    notifyListeners();
  }

  void addAll() {
    _accounts = [
      Account.a(
        40.0,
        "Account 1",
        [Account("Account 1.1"), Account("Account 1.2")],
        null,
      ),
      Account("Account 2"),
      Account("Account 3"),
      Account("Account 4"),
      Account("Account 5"),
      Account("Account 6"),
      Account("Account 7"),
      Account("Account 8"),
      Account("Account 9"),
      Account("Account 10"),
    ];
    notifyListeners();
  }

  void removeAll() {
    _accounts.clear();
    notifyListeners();
  }
}
