part of bitcoin.chaincfg;

const bool SIG_HASH_OPTIMIZATION = false;

class Params {
  final String name;
  final int pubKeyHashAddrID;
  final int scriptHashAddrID;
  final int privateKeyID;
  final Uint8List hdPrivateKeyID;
  final Uint8List hdPublicKeyID;

  final int legacyCoinType;

  Params({
    this.name,
    this.pubKeyHashAddrID,
    this.scriptHashAddrID,
    this.privateKeyID,
    this.hdPrivateKeyID,
    this.hdPublicKeyID,
    this.legacyCoinType,
  });
}
