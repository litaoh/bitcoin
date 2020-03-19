part of bitcoin.hdkeychain;

const int RecommendedSeedLen = 32; // 256 bits

/// HARDENED_KEY_START is the index at which a hardended key starts.  Each
/// extended key has 2^31 normal child keys and 2^31 hardned child keys.
/// Thus the range for normal child keys is [0, 2^31 - 1] and the range
/// for hardened child keys is [2^31, 2^32 - 1].
const int HARDENED_KEY_START = 0x80000000; // 2^31

/// MinSeedBytes is the minimum number of bytes allowed for a seed to
/// a master node.
const int MIN_SEED_BYTES = 16; // 128 bits

/// MaxSeedBytes is the maximum number of bytes allowed for a seed to
/// a master node.
const int MAX_SEED_BYTES = 64; // 512 bits

/// serializedKeyLen is the length of a serialized public or private
/// extended key.  It consists of 4 bytes version, 1 byte depth, 4 bytes
/// fingerprint, 4 bytes child number, 32 bytes chain code, and 33 bytes
/// public/private key data.
const int serializedKeyLen = 4 + 1 + 4 + 4 + 32 + 33;

/// 78 bytes

final pointycastle.ECDomainParameters ecc = ECCurve_secp256k1();

class ExtendedKey {
  Uint8List _key;
  Uint8List _chainCode;
  Uint8List _parentFP;
  Uint8List _pubKey;
  Uint8List _pubKeyHash;
  int _depth;
  int _index;
  bool _isPrivate;
  ExtendedKey(
      {Uint8List key,
      Uint8List chainCode,
      Uint8List parentFP,
      int depth,
      int index,
      bool isPrivate}) {
    _key = key;
    _chainCode = chainCode;
    _parentFP = parentFP ?? Uint8List.fromList([0, 0, 0, 0]);
    _depth = depth ?? 0;
    _index = index ?? 0;
    _isPrivate = isPrivate ?? false;
  }

  Uint8List get pubKeyBytes {
    if (!_isPrivate) {
      return _key;
    }
    if (_pubKey == null) {
      var privateKeyNum = utils.bytesToInt(_key);
      var p = ecc.G * privateKeyNum;

      _pubKey = p.getEncoded();
    }
    return _pubKey;
  }

  Uint8List get pubKeyHash {
    _pubKeyHash ??= hash160(pubKeyBytes);
    return _pubKeyHash;
  }

  ExtendedKey child(int i) {
    var isChildHardened = i >= HARDENED_KEY_START;
    if ((!_isPrivate) && isChildHardened) {
      throw FormatException('cannot derive a hardened key from a public key');
    }

    var data = ByteData(37);
    var offset = 0;
    Uint8List key;
    if (isChildHardened) {
      data.setUint8(offset, 0);
      offset++;
      key = _key;
    } else {
      key = pubKeyBytes;
    }
    for (var idx = 0; idx < key.length; idx++) {
      data.setUint8(offset, key[idx]);
      offset++;
    }

    data.setUint32(offset, i);

    var ilr = hmacSHA512(_chainCode, data.buffer.asUint8List());

    var il = ilr.sublist(0, ilr.length ~/ 2);
    var childChainCode = ilr.sublist(ilr.length ~/ 2);
    var ilNum = utils.bytesToInt(il);

    if (ilNum.compareTo(ecc.n) >= 0) {
      throw FormatException('the extended key at this index is invalid');
    }
    Uint8List childKey;
    if (_isPrivate) {
      var keyNum = utils.bytesToInt(_key);

      childKey = utils.intToBytes((ilNum + keyNum) % ecc.n);
    } else {
      var key = ecc.G * ilNum;
      var pubKey = ecc.curve.decodePoint(_key);
      var childPoint = key + pubKey;
      childKey = childPoint.getEncoded();
    }

    var parentFP = hash160(pubKeyBytes).sublist(0, 4);
    return ExtendedKey(
        key: childKey,
        chainCode: childChainCode,
        parentFP: parentFP,
        depth: _depth + 1,
        index: i,
        isPrivate: _isPrivate);
  }

  ExtendedKey neuter() {
    if (!_isPrivate) {
      return this;
    }

    return ExtendedKey(
        key: pubKeyBytes,
        chainCode: _chainCode,
        parentFP: _parentFP,
        depth: _depth,
        index: _index,
        isPrivate: false);
  }

  Uint8List ECPubKey(bool compressed) {
    var pubKey = ecc.curve.decodePoint(pubKeyBytes);
    return pubKey.getEncoded(compressed);
  }

  pointycastle.ECPrivateKey ECPrivKey() {
    return pointycastle.ECPrivateKey(utils.bytesToInt(_key), ecc);
  }

  static ExtendedKey fromPrivateKey(Uint8List privateKey, Uint8List chainCode,
      [Uint8List parentFP, int depth = 0, int index = 0]) {
    return ExtendedKey(
        key: privateKey,
        chainCode: chainCode,
        parentFP: parentFP,
        depth: depth,
        index: index,
        isPrivate: true);
  }

  static ExtendedKey fromSeed(Uint8List seed) {
    if (seed.length < MIN_SEED_BYTES) {
      throw FormatException('Seed should be at least 128 bits');
    }
    if (seed.length > MAX_SEED_BYTES) {
      throw FormatException('Seed should be at most 512 bits');
    }

    var I = hmacSHA512(Uint8List.fromList('Bitcoin seed'.codeUnits), seed);

    var IL = I.sublist(0, 32);
    var IR = I.sublist(32);
    return ExtendedKey.fromPrivateKey(IL, IR);
  }
}
