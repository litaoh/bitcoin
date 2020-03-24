part of bitcoin.utils;
/// encode address
String encodeAddress(Uint8List hash, int netID) {
  var payload = Uint8List(hash.length + 1);
  payload[0] = netID;
  payload.setRange(1, payload.length, hash);
  return Base58CheckCodec().encode(payload);
}

/// decode address
Address decodeAddress(String address) {
  var payload = Base58CheckCodec().decode(address);
  var netID = payload[0];
  var decoded = payload.sublist(1);
  var net = chaincfg.getNet();

  if (netID == net.scriptHashAddrID) {
    return AddressScriptHash(scriptHash: decoded, net: net);
  }
  throw FormatException('unknown address type');
}

class Address {
  Uint8List _hash;
  chaincfg.Params _net;
  Address({Uint8List hash, chaincfg.Params net}) {
    _hash = hash;
    _net = net;
  }
  @override
  String toString() {
    return encode();
  }

  String encode() {
    return toString();
  }

  Uint8List scriptAddress() {
    return hash160();
  }

  Uint8List hash160() {
    return _hash;
  }

  bool isForNet(chaincfg.Params net) {
    return true;
  }

  chaincfg.Params net() {
    return _net;
  }
}
