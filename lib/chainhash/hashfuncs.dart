part of bitcoins.chainhash;

/// HashB calculates hash(b) and returns the resulting bytes.
Uint8List hashB(Uint8List data) {
  var digest = SHA256Digest();
  digest.update(data, 0, data.length);
  var out = Uint8List(digest.digestSize);
  digest.doFinal(out, 0);
  return out;
}

/// HashH calculates hash(b) and returns the resulting bytes as a Hash.
Hash hashH(Uint8List data) {
  return Hash(hashB(data));
}
