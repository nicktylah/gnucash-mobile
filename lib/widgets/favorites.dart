import 'package:flutter/material.dart';
import 'package:gnucash_mobile/providers/accounts.dart';
import 'package:provider/provider.dart';

class Favorites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AccountsModel>(builder: (context, accounts, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text("Favorites"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FutureBuilder<Account>(
                    future: Provider.of<AccountsModel>(context, listen: false)
                        .favoriteDebitAccount,
                    builder: (context, AsyncSnapshot<Account> snapshot) {
                      return DropdownButton<Account>(
                        hint: Text("Favorite Debit Account"),
                        isExpanded: true,
                        // TODO: Put recently used first
                        items: accounts.validTransactionAccounts.map((account) {
                          return DropdownMenuItem(
                            value: account,
                            child: Text(
                              account.fullName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          accounts.setFavoriteDebitAccount(value);
                        },
                        value: snapshot.hasData
                            ? accounts.validTransactionAccounts.firstWhere(
                                (account) =>
                                    account.fullName == snapshot.data.fullName)
                            : null,
                      );
                    }),
                FutureBuilder<Account>(
                    future: Provider.of<AccountsModel>(context, listen: false)
                        .favoriteCreditAccount,
                    builder: (context, AsyncSnapshot<Account> snapshot) {
                      return DropdownButton<Account>(
                        hint: Text("Favorite Credit Account"),
                        isExpanded: true,
                        // TODO: Put recently used first
                        items: accounts.validTransactionAccounts.map((account) {
                          return DropdownMenuItem(
                            value: account,
                            child: Text(
                              account.fullName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          accounts.setFavoriteCreditAccount(value);
                        },
                        value: snapshot.hasData
                            ? accounts.validTransactionAccounts.firstWhere(
                                (account) =>
                                    account.fullName == snapshot.data.fullName)
                            : null,
                      );
                    }),
                Divider(
                  height: 50,
                  color: Colors.transparent,
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.primary),
                  ),
                  onPressed: () {
                    accounts.removeFavoriteDebitAccount();
                  },
                  child: Text(
                    "Clear favorite debit account",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.primary),
                  ),
                  onPressed: () {
                    accounts.removeFavoriteCreditAccount();
                  },
                  child: Text(
                    "Clear favorite credit account",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
