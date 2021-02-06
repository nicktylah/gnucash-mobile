import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gnucash_mobile/providers/accounts.dart';

void main() async {
  test("test JSON conversion", () {
    final accountString = """{
         \"balance\":0.0,
         \"children\":[
            {
               \"balance\":0.0,
               \"children\":[
                  {
                     \"balance\":0.0,
                     \"children\":[
                        
                     ],
                     \"code\":\"\",
                     \"commodityM\":\"USD\",
                     \"commodityN\":\"CURRENCY\",
                     \"color\":\"\",
                     \"description\":\"Cash in Wallet\",
                     \"fullName\":\"Assets:Current Assets:Cash in Wallet\",
                     \"hidden\":false,
                     \"name\":\"Cash in Wallet\",
                     \"notes\":\"\",
                     \"parentFullName\":\"Assets:Current Assets\",
                     \"placeholder\":false,
                     \"tax\":false,
                     \"type\":\"CASH\"
                  },
                  {
                     \"balance\":0.0,
                     \"children\":[
                        
                     ],
                     \"code\":\"\",
                     \"commodityM\":\"USD\",
                     \"commodityN\":\"CURRENCY\",
                     \"color\":\"\",
                     \"description\":\"Joint Checking Account\",
                     \"fullName\":\"Assets:Current Assets:Joint Checking Account\",
                     \"hidden\":false,
                     \"name\":\"Joint Checking Account\",
                     \"notes\":\"\",
                     \"parentFullName\":\"Assets:Current Assets\",
                     \"placeholder\":false,
                     \"tax\":false,
                     \"type\":\"ASSET\"
                  },
                  {
                     \"balance\":0.0,
                     \"children\":[
                        
                     ],
                     \"code\":\"\",
                     \"commodityM\":\"USD\",
                     \"commodityN\":\"CURRENCY\",
                     \"color\":\"\",
                     \"description\":\"Venmo Balance\",
                     \"fullName\":\"Assets:Current Assets:Venmo\",
                     \"hidden\":false,
                     \"name\":\"Venmo\",
                     \"notes\":\"\",
                     \"parentFullName\":\"Assets:Current Assets\",
                     \"placeholder\":false,
                     \"tax\":false,
                     \"type\":\"ASSET\"
                  },
                  {
                     \"balance\":0.0,
                     \"children\":[
                        
                     ],
                     \"code\":\"\",
                     \"commodityM\":\"USD\",
                     \"commodityN\":\"CURRENCY\",
                     \"color\":\"\",
                     \"description\":\"Lame ol' duck\",
                     \"fullName\":\"Assets:Current Assets:Wells Fargo Checking Account\",
                     \"hidden\":false,
                     \"name\":\"Wells Fargo Checking Account\",
                     \"notes\":\"\",
                     \"parentFullName\":\"Assets:Current Assets\",
                     \"placeholder\":false,
                     \"tax\":false,
                     \"type\":\"ASSET\"
                  },
                  {
                     \"balance\":0.0,
                     \"children\":[
                        
                     ],
                     \"code\":\"\",
                     \"commodityM\":\"USD\",
                     \"commodityN\":\"CURRENCY\",
                     \"color\":\"\",
                     \"description\":\"Checking Account\",
                     \"fullName\":\"Assets:Current Assets:Checking Account\",
                     \"hidden\":false,
                     \"name\":\"Checking Account\",
                     \"notes\":\"\",
                     \"parentFullName\":\"Assets:Current Assets\",
                     \"placeholder\":false,
                     \"tax\":false,
                     \"type\":\"BANK\"
                  },
                  {
                     \"balance\":0.0,
                     \"children\":[
                        
                     ],
                     \"code\":\"\",
                     \"commodityM\":\"USD\",
                     \"commodityN\":\"CURRENCY\",
                     \"color\":\"\",
                     \"description\":\"Savings Account\",
                     \"fullName\":\"Assets:Current Assets:Savings Account\",
                     \"hidden\":false,
                     \"name\":\"Savings Account\",
                     \"notes\":\"\",
                     \"parentFullName\":\"Assets:Current Assets\",
                     \"placeholder\":false,
                     \"tax\":false,
                     \"type\":\"BANK\"
                  }
               ],
               \"code\":\"\",
               \"commodityM\":\"USD\",
               \"commodityN\":\"CURRENCY\",
               \"color\":\"\",
               \"description\":\"Current Assets\",
               \"fullName\":\"Assets:Current Assets\",
               \"hidden\":false,
               \"name\":\"Current Assets\",
               \"notes\":\"\",
               \"parentFullName\":\"Assets\",
               \"placeholder\":true,
               \"tax\":false,
               \"type\":\"ASSET\"
            },
            {
               \"balance\":0.0,
               \"children\":[
                  {
                     \"balance\":0.0,
                     \"children\":[
                        
                     ],
                     \"code\":\"\",
                     \"commodityM\":\"USD\",
                     \"commodityN\":\"CURRENCY\",
                     \"color\":\"\",
                     \"description\":\"MS Brokerage Account\",
                     \"fullName\":\"Assets:Investments:MS Brokerage Account\",
                     \"hidden\":false,
                     \"name\":\"MS Brokerage Account\",
                     \"notes\":\"\",
                     \"parentFullName\":\"Assets:Investments\",
                     \"placeholder\":false,
                     \"tax\":false,
                     \"type\":\"ASSET\"
                  },
                  {
                     \"balance\":0.0,
                     \"children\":[
                        
                     ],
                     \"code\":\"\",
                     \"commodityM\":\"USD\",
                     \"commodityN\":\"CURRENCY\",
                     \"color\":\"\",
                     \"description\":\"MS Brokerage Account\",
                     \"fullName\":\"Assets:Investments:MS Brokerage Account\",
                     \"hidden\":false,
                     \"name\":\"MS Brokerage Account\",
                     \"notes\":\"\",
                     \"parentFullName\":\"Assets:Investments\",
                     \"placeholder\":false,
                     \"tax\":false,
                     \"type\":\"ASSET\"
                  },
                  {
                     \"balance\":0.0,
                     \"children\":[
                        
                     ],
                     \"code\":\"\",
                     \"commodityM\":\"USD\",
                     \"commodityN\":\"CURRENCY\",
                     \"color\":\"\",
                     \"description\":\"MS Brokerage Account\",
                     \"fullName\":\"Assets:Investments:MS Brokerage Account\",
                     \"hidden\":false,
                     \"name\":\"MS Brokerage Account\",
                     \"notes\":\"\",
                     \"parentFullName\":\"Assets:Investments\",
                     \"placeholder\":false,
                     \"tax\":false,
                     \"type\":\"ASSET\"
                  },
                  {
                     \"balance\":0.0,
                     \"children\":[
                        
                     ],
                     \"code\":\"\",
                     \"commodityM\":\"USD\",
                     \"commodityN\":\"CURRENCY\",
                     \"color\":\"\",
                     \"description\":\"MS REG\",
                     \"fullName\":\"Assets:Investments:MS REG\",
                     \"hidden\":false,
                     \"name\":\"MS REG\",
                     \"notes\":\"\",
                     \"parentFullName\":\"Assets:Investments\",
                     \"placeholder\":false,
                     \"tax\":false,
                     \"type\":\"ASSET\"
                  },
                  {
                     \"balance\":0.0,
                     \"children\":[
                        
                     ],
                     \"code\":\"\",
                     \"commodityM\":\"USD\",
                     \"commodityN\":\"CURRENCY\",
                     \"color\":\"\",
                     \"description\":\"MS Select UMA\",
                     \"fullName\":\"Assets:Investments:MS Select UMA\",
                     \"hidden\":false,
                     \"name\":\"MS Select UMA\",
                     \"notes\":\"\",
                     \"parentFullName\":\"Assets:Investments\",
                     \"placeholder\":false,
                     \"tax\":false,
                     \"type\":\"ASSET\"
                  },
                  {
                     \"balance\":0.0,
                     \"children\":[
                        {
                           \"balance\":0.0,
                           \"children\":[
                              
                           ],
                           \"code\":\"\",
                           \"commodityM\":\"USD\",
                           \"commodityN\":\"CURRENCY\",
                           \"color\":\"\",
                           \"description\":\"GG 401k\",
                           \"fullName\":\"Assets:Investments:Retirement:GG 401k\",
                           \"hidden\":false,
                           \"name\":\"GG 401k\",
                           \"notes\":\"\",
                           \"parentFullName\":\"Assets:Investments:Retirement\",
                           \"placeholder\":false,
                           \"tax\":false,
                           \"type\":\"BANK\"
                        },
                        {
                           \"balance\":0.0,
                           \"children\":[
                              
                           ],
                           \"code\":\"\",
                           \"commodityM\":\"USD\",
                           \"commodityN\":\"CURRENCY\",
                           \"color\":\"\",
                           \"description\":\"MS IRA\",
                           \"fullName\":\"Assets:Investments:Retirement:MS IRA\",
                           \"hidden\":false,
                           \"name\":\"MS IRA\",
                           \"notes\":\"\",
                           \"parentFullName\":\"Assets:Investments:Retirement\",
                           \"placeholder\":false,
                           \"tax\":false,
                           \"type\":\"BANK\"
                        }
                     ],
                     \"code\":\"\",
                     \"commodityM\":\"USD\",
                     \"commodityN\":\"CURRENCY\",
                     \"color\":\"\",
                     \"description\":\"Retirement\",
                     \"fullName\":\"Assets:Investments:Retirement\",
                     \"hidden\":false,
                     \"name\":\"Retirement\",
                     \"notes\":\"IRA, 401(k), or other retirement\",
                     \"parentFullName\":\"Assets:Investments\",
                     \"placeholder\":true,
                     \"tax\":false,
                     \"type\":\"BANK\"
                  }
               ],
               \"code\":\"\",
               \"commodityM\":\"USD\",
               \"commodityN\":\"CURRENCY\",
               \"color\":\"\",
               \"description\":\"Investments\",
               \"fullName\":\"Assets:Investments\",
               \"hidden\":false,
               \"name\":\"Investments\",
               \"notes\":\"\",
               \"parentFullName\":\"Assets\",
               \"placeholder\":true,
               \"tax\":false,
               \"type\":\"ASSET\"
            }
         ],
         \"code\":\"\",
         \"commodityM\":\"USD\",
         \"commodityN\":\"CURRENCY\",
         \"color\":\"\",
         \"description\":\"Assets\",
         \"fullName\":\"Assets\",
         \"hidden\":false,
         \"name\":\"Assets\",
         \"notes\":\"\",
         \"parentFullName\":\"\",
         \"placeholder\":true,
         \"tax\":false,
         \"type\":\"ASSET\"
      }""";
    final dynamic = jsonDecode(accountString);
    final Account account = Account.fromJson(dynamic);
    // final account = Account.fromJson({"account": accountString});
    final accountJson = jsonEncode(account);

    print("Account");
    print(account.children[0]);
    // print("Account JSON");
    // print(accountJson);
    assert(account.fullName == "Assets");
    assert(account.children.length == 2);
    // assert(accountString == accountJson);
  });

  // AccountsModel _accountsModel = AccountsModel();
  // _accountsModel.addAll();
  //
  // final accounts = await _accountsModel.accounts;
  //
  // assert(accounts.length == 7);
  //
  // final toTest = accounts[0];
  // assert(toTest.type == 'ASSET');
  // assert(toTest.fullName == 'Assets');
  // assert(toTest.name == 'Assets');
  // assert(toTest.code == '');
  // assert(toTest.description == 'Assets');
  // assert(toTest.color == '');
  // assert(toTest.notes == '');
  // assert(toTest.commodityM == 'USD');
  // assert(toTest.commodityN == 'CURRENCY');
  // assert(toTest.hidden == false);
  // assert(toTest.tax == false);
  // assert(toTest.parentFullName == '');
  // assert(toTest.placeholder == true);
  // assert(toTest.parent == null);
  //
  // final _children = toTest.children;
  // assert(_children.length == 2);
  // assert(_children[0].fullName == "Assets:Current Assets");
  //
  // final _childrensChildren = _children[0].children;
  // assert(_childrensChildren.length == 6);
  // assert(_childrensChildren[0].fullName ==
  //     "Assets:Current Assets:Cash in Wallet");
}
