import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String parentFullName; // non-standard
  bool placeholder; // Whether transactions can be placed in this account?
  bool tax;
  String type;
  String name;

  Account.fromJson(Map<String, dynamic> json) {
    this.balance = json['balance'];
    this.children = [];
    if (json['children'] != null) {
      final List<dynamic> rawChildren = json['children'];
      rawChildren.forEach((element) {
        this.children.add(Account.fromJson(element));
      });
    }
    code = json['code'];
    commodityM = json['commodityM'];
    commodityN = json['commodityN'];
    color = json['color'];
    description = json['description'];
    fullName = json['fullName'];
    hidden = json['hidden'];
    name = json['name'];
    notes = json['notes'];
    parentFullName = json['parentFullName'];
    placeholder = json['placeholder'];
    tax = json['tax'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final json = {
      'balance': balance,
      'children': children,
      'code': code,
      'commodityM': commodityM,
      'commodityN': commodityN,
      'color': color,
      'description': description,
      'fullName': fullName,
      'hidden': hidden,
      'name': name,
      'notes': notes,
      'parentFullName': parentFullName,
      'placeholder': placeholder,
      'tax': tax,
      'type': type
    };

    return json;
  }

  Account.fromList(List<dynamic> items) {
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
    return "Account{balance: ${this.balance}, children: List<Account>[${this.children ?? [].length}], code: ${this.code}, commodityM: ${this.commodityM}, commodityN: ${this.commodityN}, color: ${this.color}, description: ${this.description}, fullName: ${this.fullName}, hidden: ${this.hidden}, notes: ${this.notes}, parentFullName: ${this.parentFullName}, placeholder: ${this.placeholder}, tax: ${this.tax}, type: ${this.type}, name: ${this.name}}";
  }
}

class AccountsModel extends ChangeNotifier {
  final _prefs = SharedPreferences.getInstance();

  Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/accounts.csv');
  }

  List<Account> _validTransactionAccounts = [];

  Future<Account> get favoriteDebitAccount async {
    final prefs = await _prefs;
    final favoriteDebitAccountString = prefs.getString('favoriteDebitAccount');

    if (favoriteDebitAccountString != null) {
      return Account.fromJson(jsonDecode(favoriteDebitAccountString));
    } else {
      return null;
    }
  }

  void setFavoriteDebitAccount(Account account) async {
    final prefs = await _prefs;
    await prefs.setString('favoriteDebitAccount', jsonEncode(account));

    notifyListeners();
  }

  void removeFavoriteDebitAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favoriteDebitAccount');

    notifyListeners();
  }

  Future<Account> get favoriteCreditAccount async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteCreditAccountString = prefs.getString('favoriteCreditAccount') ?? null;

    if (favoriteCreditAccountString != null) {
      return Account.fromJson(jsonDecode(favoriteCreditAccountString));
    } else {
      return null;
    }
  }

  void setFavoriteCreditAccount(Account account) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favoriteCreditAccount', jsonEncode(account));

    notifyListeners();
  }

  void removeFavoriteCreditAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favoriteCreditAccount');

    notifyListeners();
  }

  final List<Account> _recentCreditAccounts = [];
  final List<Account> _recentDebitAccounts = [];

  UnmodifiableListView<Account> get validTransactionAccounts =>
      UnmodifiableListView(_validTransactionAccounts);

  UnmodifiableListView<Account> get recentCreditAccounts =>
      UnmodifiableListView(_recentCreditAccounts);
  UnmodifiableListView<Account> get recentDebitAccounts =>
      UnmodifiableListView(_recentDebitAccounts);

  List<Account> parseAccountCSV(String csv) {
    var _detector = new FirstOccurrenceSettingsDetector(
      eols: ['\r\n', '\n'],
    );

    final _converter = CsvToListConverter(
      csvSettingsDetector: _detector,
      textDelimiter: '"',
      shouldParseNumbers: false,
    );

    final _parsed = _converter.convert(csv.trim());
    // Remove header row
    _parsed.removeAt(0);

    final _accounts = <Account>[];
    final _transactionAccounts = <Account>[];
    for (var line in _parsed) {
      final _account = Account.fromList(line);
      final _lastIndex = _account.fullName.lastIndexOf(":");
      final _hasParent = _lastIndex > 0;
      var _parentFullName = '';
      if (_hasParent) {
        _parentFullName = _account.fullName.substring(0, _lastIndex);
      }

      _account.parentFullName = _parentFullName;
      _accounts.add(_account);

      if (!_account.placeholder) {
        // This account is valid to make transactions to/from
        _transactionAccounts.add(_account);
      }
    }
    _validTransactionAccounts = _transactionAccounts;

    return _buildAccountsTree(_accounts);
  }

  static List<Account> _buildAccountsTree(List<Account> accounts) {
    final _lookup = Map<String, Account>();
    final List<Account> _hierarchicalAccounts = [];

    for (var _account in accounts) {
      if (_lookup.containsKey(_account.parentFullName)) {
        final _parent = _lookup[_account.parentFullName];
        _parent.children.add(_account);
      } else {
        _hierarchicalAccounts.add(_account);
      }

      _lookup[_account.fullName] = _account;
    }

    return _hierarchicalAccounts;
  }

  Future<List<Account>> get accounts async {
    final file = await _localFile;
    String csvString = await file.readAsString();
    final _parsedAccounts = parseAccountCSV(csvString);
    return _parsedAccounts;
  }

  void addAll(String csv) async {
    final file = await _localFile;
    file.writeAsString(csv);

    notifyListeners();
  }

  void removeAll() async {
    final file = await _localFile;
    file.delete();

    notifyListeners();
  }

}
