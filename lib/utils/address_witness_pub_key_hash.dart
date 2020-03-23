part of bitcoin.utils;

class AddressWitnessPubKeyHash extends Address {
  int witnessVersion;
  String hrp;
  AddressWitnessPubKeyHash({Uint8List scriptHash, chaincfg.Params net})
      : super(hash: scriptHash, net: net) {
    hrp = net.bech32HRPSegwit.toLowerCase();
    witnessVersion = 0x00;
  }
}
