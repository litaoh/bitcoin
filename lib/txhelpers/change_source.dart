part of bitcoins.txhelpers;

class ChangeSource {
  Uint8List _hash;
  int _version;
  ChangeSource(String address) {
    if (address?.isNotEmpty ?? false) {
      _hash = txscript.payToAddrScript(utils.decodeAddress(address));
    }
    _version = txscript.DEFAULT_SCRIPT_VERSION;
  }
  Uint8List get hash => _hash;
  int get version => _version;

  void script() {}
  int scriptSize() {
    return _hash.length;
  }
}
