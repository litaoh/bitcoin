part of bitcoins.utils;

/// bitcoin PubKey Hash address
class AddressPubKeyHash extends Address {
  int _netID;
  AddressPubKeyHash({Uint8List hash, chaincfg.Params net})
      : super(hash: hash, net: net) {
    _netID = net.pubKeyHashAddrID;
  }

  @override
  String encode() {
    return encodeAddress(_hash, _netID);
  }
}
