part of bitcoins.hdkeychain;

/// hash160 returns RIPEMD160(SHA256(v)).
Uint8List hash160(Uint8List buffer) {
  return RIPEMD160().update(chainhash.hashB(buffer)).digest();
}

/// hmacSHA512 returns HMAC SHA-512.
Uint8List hmacSHA512(Uint8List key, Uint8List data) {
  return Hmac(SHA512(), key).update(data).digest();
}
