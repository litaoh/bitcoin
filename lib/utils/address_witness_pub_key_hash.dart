part of bitcoins.utils;

class AddressWitnessPubKeyHash extends Address {
  int witnessVersion;
  String hrp;
  AddressWitnessPubKeyHash({Uint8List hash, chaincfg.Params net})
      : super(hash: hash, net: net) {
    hrp = net.bech32HRPSegwit.toLowerCase();
    witnessVersion = 0x00;
  }
}
