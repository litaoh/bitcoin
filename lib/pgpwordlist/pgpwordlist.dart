library bitcoins.pgpwordlist;

import 'dart:typed_data';
import 'package:hash/hash.dart';

part 'wordlist.dart';

/// decode mnemonics
Uint8List decodeMnemonics(String mnemonic) {
  return _PBKDF2Key(Uint8List.fromList(mnemonic.codeUnits),
      Uint8List.fromList('mnemonic'.codeUnits), 2048, 64, SHA512());
}

Uint8List _PBKDF2Key(
    Uint8List password, Uint8List salt, int iter, int keyLen, BlockHash hash) {
  var prf = Hmac(hash, password);
  var hashLen = prf.outSize;

  var numBlocks = (keyLen + hashLen - 1) ~/ hashLen;
  var buf = Uint8List(4);
  var dk = Uint8List(0);
  var U = Uint8List(hashLen);
  for (var block = 1; block <= numBlocks; block++) {
    prf.update(salt);
    buf[0] = block >> 24;
    buf[1] = block >> 16;
    buf[2] = block >> 8;
    buf[3] = block;
    prf.update(buf);
    dk = prf.digest();
    var start = dk.length - hashLen;
    U = dk.sublist(start);

    for (var n = 2; n <= iter; n++) {
      prf.reset();
      prf.update(U);
      U = prf.digest();
      for (var i = 0; i < U.length; i++) {
        dk[start + i] ^= U[i];
      }
    }
  }
  return dk.sublist(0, keyLen);
}
