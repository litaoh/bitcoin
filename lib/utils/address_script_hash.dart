part of bitcoins.utils;

class AddressScriptHash extends Address {
  int _netID;
  AddressScriptHash({Uint8List scriptHash, chaincfg.Params net})
      : super(hash: scriptHash, net: net) {
    _netID = net.scriptHashAddrID;
  }

  @override
  String encode() {
    return encodeAddress(_hash, _netID);
  }
}
