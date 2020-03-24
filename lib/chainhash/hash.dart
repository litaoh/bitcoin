part of bitcoin.chainhash;

/// HashSize of array used to store hashes.  See Hash.
const HASH_SIZE = 32;

/// MaxHashStringSize is the maximum length of a Hash hash string.
const MAX_HASH_STRING_SIZE = HASH_SIZE * 2;

class Hash {
  Uint8List _hash;
  Hash(this._hash);

  Uint8List cloneBytes() {
    return Uint8List.fromList(_hash);
  }

  int get length {
    return _hash.length;
  }

  Hash.fromString(String src) {
    if ((src?.isEmpty ?? true) || src.length > MAX_HASH_STRING_SIZE) {
      throw FormatException(
          'max hash string length is ${MAX_HASH_STRING_SIZE} bytes');
    }
    var len = src.length;

    var srcBytes = ByteData(len ~/ 2);

    copyBytes(srcBytes, utils.hexToBytes(src), 0);

    if (len % 2 != 0) {
      var bytes = ByteData(len + 1);
      bytes.setUint8(0, 0);
      copyBytes(bytes, srcBytes.buffer.asUint8List(), 1);
      srcBytes = bytes;
    }

    var reversedHash = ByteData(srcBytes.lengthInBytes);
    for (var i = 0; i < HASH_SIZE / 2; i++) {
      reversedHash.setUint8(i, srcBytes.getUint8(HASH_SIZE - 1 - i));
      reversedHash.setUint8(HASH_SIZE - 1 - i, srcBytes.getUint8(i));
    }
    _hash = reversedHash.buffer.asUint8List();
  }

  @override
  String toString() {
    var reversedHash = ByteData(_hash.lengthInBytes);
    for (var i = 0; i < HASH_SIZE / 2; i++) {
      reversedHash.setUint8(i, _hash[HASH_SIZE - 1 - i]);
      reversedHash.setUint8(HASH_SIZE - 1 - i, _hash[i]);
    }
    return utils.bytesToHex(reversedHash.buffer.asUint8List());
  }
}
