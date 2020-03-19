part of bitcoin.txscript;

class KeyClosure {
  final Function _getKey;
  KeyClosure(this._getKey);
  KeyClosureResp getKey(utils.Address addr) {
    return _getKey(addr);
  }
}

class KeyClosureResp {
  final pointycastle.ECPrivateKey key;
  final bool compressed;
  KeyClosureResp({this.key, this.compressed});
}
