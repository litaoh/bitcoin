part of bitcoin.wallet;

class AddressBuffer {
  final hdkeychain.ExtendedKey branchXpub;
  final int lastUsed;
  int cursor;
  AddressBuffer({this.branchXpub, this.lastUsed, this.cursor});
}
