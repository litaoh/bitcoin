part of bitcoin.txhelpers;

class P2PKHChangeSource extends ChangeSource {
  final int account;
  final WalletBTC wallet;
  P2PKHChangeSource({this.account, this.wallet}) : super('');
  @override
  void script() {
    var changeAddress = wallet.newInternalAddress(account, GAP_POLICY_WRAP);
    print(changeAddress.hash160());
    _hash = txscript.payToAddrScript(changeAddress);
    print(_hash);
    _version = txscript.DEFAULT_SCRIPT_VERSION;
  }

  @override
  int scriptSize() {
    return txsizes.P2PKH_PK_SCRIPT_SIZE;
  }
}
