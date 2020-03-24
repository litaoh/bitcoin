library bitcoins.pgpwordlist;

import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/key_derivators/api.dart' show Pbkdf2Parameters;
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

part 'wordlist.dart';

/// decode mnemonics
Uint8List decodeMnemonics(String mnemonic) {
  var derivator = PBKDF2KeyDerivator(new HMac(new SHA512Digest(), 128))
    ..init(new Pbkdf2Parameters(utf8.encode('mnemonic'), 2048, 64));

  return derivator.process(new Uint8List.fromList(mnemonic.codeUnits));
}
