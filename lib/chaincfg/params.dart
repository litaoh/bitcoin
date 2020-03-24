part of bitcoins.chaincfg;

class Params {
  final String name;

  final String bech32HRPSegwit;
  final int pubKeyHashAddrID;
  final int scriptHashAddrID;
  final int privateKeyID;
  final Uint8List hdPrivateKeyID;
  final Uint8List hdPublicKeyID;
  final int legacyCoinType;

  Params({
    this.name,
    this.bech32HRPSegwit,
    this.pubKeyHashAddrID,
    this.scriptHashAddrID,
    this.privateKeyID,
    this.hdPrivateKeyID,
    this.hdPublicKeyID,
    this.legacyCoinType,
  });
}
