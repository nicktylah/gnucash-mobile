# GnuCash Mobile

An application for keeping track of GnuCash transactions on the go.

Note: this app is not meant to be a standalone implementation of GnuCash. Rather, it's a simple tool for recording transactions as they happen that also allows you to export in a GnuCash-compatible format (CSV).

Capabilities:
  - Import a set of accounts (these should be exported from a valid GnuCash instance; `File > Export > Export Account Tree to CSV...`)
  - Create transactions a GnuCash-compatible, double-bookkeeping fashion
  - Export said transactions for import into a standalone GnuCash instance (`File > Import > Import Transactions from CSV...`). Use the "GnuCash Export Format".
  - Set favorite debit and credit accounts for pre-populating transaction fields.