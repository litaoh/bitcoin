part of bitcoin.txhelpers;

class P2PKHChangeSource extends ChangeSource {
  final int account;
  final WalletBTC wallet;
  P2PKHChangeSource({this.account, this.wallet}) : super('');
  @override
  void script() {
    var changeAddress = wallet.newInternalAddress(account);
    _hash = txscript.payToAddrScript(changeAddress);
    _version = txscript.DEFAULT_SCRIPT_VERSION;
  }

  @override
  int scriptSize() {
    return txsizes.P2PKH_PK_SCRIPT_SIZE;
  }
}
