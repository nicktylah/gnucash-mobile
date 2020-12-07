import 'package:flutter_test/flutter_test.dart';

import 'package:gnucash_mobile/providers/accounts.dart';

final testCSV = """
ASSET,Assets,Assets,,Assets,,,USD,CURRENCY,F,F,T
ASSET,Assets:Current Assets,Current Assets,,Current Assets,,,USD,CURRENCY,F,F,T
""";

// Example CSV dump from GnuCash
final exampleCSV = """
  type,full_name,name,code,description,color,notes,commoditym,commodityn,hidden,tax,placeholder
  ASSET,Assets,Assets,,Assets,,,USD,CURRENCY,F,F,T
  ASSET,Assets:Current Assets,Current Assets,,Current Assets,,,USD,CURRENCY,F,F,T
  CASH,Assets:Current Assets:Cash in Wallet,Cash in Wallet,,Cash in Wallet,,,USD,CURRENCY,F,F,F
  ASSET,Assets:Current Assets:Joint Checking Account,Joint Checking Account,,Chase Checking Account w/ Hayla,,,USD,CURRENCY,F,F,F
  ASSET,Assets:Current Assets:Venmo,Venmo,,Venmo Balance,,,USD,CURRENCY,F,F,F
  ASSET,Assets:Current Assets:Wells Fargo Checking Account,Wells Fargo Checking Account,,Lame ol' duck,,,USD,CURRENCY,F,F,F
  BANK,Assets:Current Assets:Checking Account,Checking Account,,Checking Account,,,USD,CURRENCY,F,F,F
  BANK,Assets:Current Assets:Savings Account,Savings Account,,Savings Account,,,USD,CURRENCY,F,F,F
  """;

void main() {
  test('Parse accounts CSV', () {
    final result = AccountsModel.parseAccountCSV(exampleCSV);
    assert(result.length == 1);

    final toTest = result[0];
    assert(toTest.type == 'ASSET');
    assert(toTest.fullName == 'Assets');
    assert(toTest.name == 'Assets');
    assert(toTest.code == '');
    assert(toTest.description == 'Assets');
    assert(toTest.color == '');
    assert(toTest.notes == '');
    assert(toTest.commodityM == 'USD');
    assert(toTest.commodityN == 'CURRENCY');
    assert(toTest.hidden == false);
    assert(toTest.tax == false);
    assert(toTest.parentFullName == '');
    assert(toTest.placeholder == true);
    assert(toTest.parent == null);
    assert(toTest.children.length == 1);

    final _children = toTest.children;
    assert(_children.length == 1);
    assert(_children[0].fullName == "Assets:Current Assets");

    final _childrensChildren = _children[0].children;
    assert(_childrensChildren.length == 6);
    assert(_childrensChildren[0].fullName == "Assets:Current Assets:Cash in Wallet");
  });
}
