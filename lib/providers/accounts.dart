import 'dart:collection';

import 'package:flutter/foundation.dart';

class AccountsModel extends ChangeNotifier {
  List<Account> _accounts = [];

  final Account _favoriteAccount = null;
  final List<Account> _recentCreditAccounts = [];
  final List<Account> _recentDebitAccounts = [];

  UnmodifiableListView<Account> get accounts => UnmodifiableListView(_accounts);
  UnmodifiableListView<Account> get recentCreditAccounts => UnmodifiableListView(_recentCreditAccounts);
  UnmodifiableListView<Account> get recentDebitAccounts => UnmodifiableListView(_recentDebitAccounts);

  // Test function to simulate adding bunch o' accounts
  void addAll() {
    _accounts = [
      Account.a(null, "Account 1", [Account("Account 1.1"), Account("Account 1.2")]),
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

  void add(Account account) {
    _accounts.add(account);
    notifyListeners();
  }

  void removeAll() {
    _accounts.clear();
    notifyListeners();
  }
}

class Account {
  Account parent;
  String name;
  List<Account> children;

  Account(String name) {
    this.name = name;
  }

  Account.a(Account parent, String name, List<Account> children) {
    this.name = name;
    this.parent = parent;
    this.children = children;
  }
}