part of bitcoin.utils;

String encodeAddress(Uint8List hash, int netID) {
  var payload = Uint8List(hash.length + 1);
  payload[0] = netID;
  payload.setRange(1, payload.length, hash);
  return Base58CheckCodec().encode(payload);
}

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

chaincfg.Params _detectNetworkForAddress(int netID) {
  if (netID == chaincfg.mainnet.scriptHashAddrID) {
    return chaincfg.mainnet;
  } else if (netID == chaincfg.testnet3.scriptHashAddrID) {
    return chaincfg.testnet3;
  }
  return null;
}


class Address {
  Uint8List _hash;
  chaincfg.Params _net;
  Address();
  @override
  String toString() {
    return super.toString();
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
