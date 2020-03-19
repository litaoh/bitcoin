part of bitcoin.hdkeychain;

/// hash160 returns RIPEMD160(SHA256(v)).
Uint8List hash160(Uint8List buffer) {
  var hash = chainhash.hashB(buffer);
  var hash160 = RIPEMD160Digest();
  hash160.update(hash, 0, hash.length);
  var out = Uint8List(hash160.digestSize);
  hash160.doFinal(out, 0);
  return out;
}

/// hmacSHA512 returns HMAC SHA-512.
Uint8List hmacSHA512(Uint8List key, Uint8List data) {
  var digest = pointycastle.Digest('SHA-512');
  var hmac = HMac(digest, 128);
  hmac.init(pointycastle.KeyParameter(key));
  hmac.update(data, 0, data.length);
  var out = Uint8List(hmac.macSize);
  hmac.doFinal(out, 0);
  return out;
}
