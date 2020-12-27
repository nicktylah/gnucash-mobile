import 'package:gnucash_mobile/providers/accounts.dart';

void main() {
  AccountsModel _accountsModel = AccountsModel();
  _accountsModel.addAll();

  assert(_accountsModel.accounts.length == 7);

  final toTest = _accountsModel.accounts[0];
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

  final _children = toTest.children;
  assert(_children.length == 2);
  assert(_children[0].fullName == "Assets:Current Assets");

  final _childrensChildren = _children[0].children;
  assert(_childrensChildren.length == 6);
  assert(_childrensChildren[0].fullName ==
      "Assets:Current Assets:Cash in Wallet");
}
