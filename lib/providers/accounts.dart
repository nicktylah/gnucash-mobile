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

  // Test function to simulate adding bunch o' accounts
  void addAll() async {
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
ASSET,Assets:Investments,Investments,,Investments,,,USD,CURRENCY,F,F,T
ASSET,Assets:Investments:MS Brokerage Account,MS Brokerage Account,,MS Brokerage Account,,,USD,CURRENCY,F,F,F
ASSET,Assets:Investments:MS Brokerage Account,MS Brokerage Account,,MS Brokerage Account,,,USD,CURRENCY,F,F,F
ASSET,Assets:Investments:MS Brokerage Account,MS Brokerage Account,,MS Brokerage Account,,,USD,CURRENCY,F,F,F
ASSET,Assets:Investments:MS REG,MS REG,,MS REG,,,USD,CURRENCY,F,F,F
ASSET,Assets:Investments:MS Select UMA,MS Select UMA,,MS Select UMA,,,USD,CURRENCY,F,F,F
BANK,Assets:Investments:Retirement,Retirement,,Retirement,,"IRA, 401(k), or other retirement",USD,CURRENCY,F,F,T
BANK,Assets:Investments:Retirement:GG 401k,GG 401k,,GG 401k,,,USD,CURRENCY,F,F,F
BANK,Assets:Investments:Retirement:MS IRA,MS IRA,,MS IRA,,,USD,CURRENCY,F,F,F
LIABILITY,Liabilities,Liabilities,,Liabilities,,,USD,CURRENCY,F,F,T
CREDIT,Liabilities:AMEX,AMEX,,Morgan Stanley Platinum Card -11001,,,USD,CURRENCY,F,F,F
LIABILITY,Liabilities:AMEX Blue,AMEX Blue,,Grocery Card,,,USD,CURRENCY,F,F,F
LIABILITY,Liabilities:Bank of America,Bank of America,,Travel Rewards,,,USD,CURRENCY,F,F,F
LIABILITY,Liabilities:Chase Freedom,Chase Freedom,,Freedom Unlimited,,,USD,CURRENCY,F,F,F
LIABILITY,Liabilities:Chase Sapphire,Chase Sapphire,,Sapphire Preferred,,,USD,CURRENCY,F,F,F
INCOME,Income,Income,,Income,,,USD,CURRENCY,F,F,T
INCOME,Income:Bonus,Bonus,,Bonus,,,USD,CURRENCY,F,F,F
INCOME,Income:Dividend Income,Dividend Income,,Dividend Income,,,USD,CURRENCY,F,F,F
INCOME,Income:Gifts Received,Gifts Received,,Gifts Received,,,USD,CURRENCY,F,F,F
INCOME,Income:Interest Income,Interest Income,,Interest Income,,,USD,CURRENCY,F,F,F
INCOME,Income:Interest Income:Bond Interest,Bond Interest,,Bond Interest,,,USD,CURRENCY,F,F,F
INCOME,Income:Interest Income:Checking Interest,Checking Interest,,Checking Interest,,,USD,CURRENCY,F,F,F
INCOME,Income:Interest Income:Other Interest,Other Interest,,Other Interest,,,USD,CURRENCY,F,F,F
INCOME,Income:Interest Income:Savings Interest,Savings Interest,,Savings Interest,,,USD,CURRENCY,F,F,F
INCOME,Income:Other Income,Other Income,,Other Income,,,USD,CURRENCY,F,F,F
INCOME,Income:Salary,Salary,,Salary,,,USD,CURRENCY,F,F,F
EXPENSE,Expenses,Expenses,,Expenses,"rgb(255,133,133)",,USD,CURRENCY,F,F,T
EXPENSE,Expenses:Auto,Auto,,Auto,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Auto:Fees,Fees,,Fees,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Auto:Gas,Gas,,Gas,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Auto:Parking,Parking,,Parking,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Auto:Repair and Maintenance,Repair and Maintenance,,Repair and Maintenance,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Books,Books,,Books,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Charity,Charity,,Charity,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Clothes,Clothes,,Clothes,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Computer,Computer,,Computer,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Education,Education,,Education,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Entertainment,Entertainment,,Entertainment,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Entertainment:Music/Movies,Music/Movies,,Music/Movies,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Entertainment:Recreation,Recreation,,Recreation,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Entertainment:Travel,Travel,,Travel,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Food,Food,,All things ingestible,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Food:Delivery,Delivery,,,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Food:Groceries,Groceries,,Groceries,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Food:Groceries:Alcohol,Alcohol,,Boozin',"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,"Expenses:Food:Restaurants, Bars","Restaurants, Bars",,Dining,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,"Expenses:Food:Restaurants, Bars:Coffee Shops",Coffee Shops,,Caffeinin',"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Gifts,Gifts,,Gifts,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Hobbies,Hobbies,,Hobbies,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Home,Home,,Home,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Home:Cleaning,Cleaning,,Cleaning,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Home:Rent,Rent,,Gotta live somewhere,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Insurance,Insurance,,Insurance,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Insurance:Auto Insurance,Auto Insurance,,Auto Insurance,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Insurance:Dental Insurance,Dental Insurance,,Dental Insurance,,,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Insurance:Health Insurance,Health Insurance,,Health Insurance,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Insurance:Life Insurance,Life Insurance,,Life Insurance,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Laundry/Dry Cleaning,Laundry/Dry Cleaning,,Laundry/Dry Cleaning,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Medical Expenses,Medical Expenses,,Medical Expenses,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Miscellaneous,Miscellaneous,,Miscellaneous,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Online Services,Online Services,,Online Services,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Subscriptions,Subscriptions,,Subscriptions,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Supplies,Supplies,,Supplies,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Taxes,Taxes,,Taxes,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Taxes:Federal,Federal,,Federal,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Taxes:Medicare,Medicare,,Medicare,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Taxes:Other Tax,Other Tax,,Other Tax,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Taxes:Social Security,Social Security,,Social Security,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Taxes:State/Province,State/Province,,State/Province,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Transportation,Transportation,,Public Transportation,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Utilities,Utilities,,Utilities,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Utilities:Electric,Electric,,Electric,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Utilities:Gas,Gas,,Gas,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Utilities:Internet,Internet,,Internet,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EXPENSE,Expenses:Utilities:Phone,Phone,,Phone,"rgb(255,133,133)",,USD,CURRENCY,F,F,F
EQUITY,Equity,Equity,,Equity,,,USD,CURRENCY,F,F,T
EQUITY,Equity:Opening Balances,Opening Balances,,Opening Balances,,,USD,CURRENCY,F,F,F
BANK,Imbalance-USD,Imbalance-USD,,,,,USD,CURRENCY,F,F,F
BANK,Orphan-USD,Orphan-USD,,,,,USD,CURRENCY,F,F,F
  """;
    final file = await _localFile;
    file.writeAsString(exampleCSV);

    notifyListeners();
  }

  void removeAll() async {
    final file = await _localFile;
    file.delete();

    notifyListeners();
  }

}
