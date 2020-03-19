library bitcoin.wallet.seed;

import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart' show SHA256Digest;

import '../../pgpwordlist/pgpwordlist.dart'
    show decodeMnemonics, byteToMnemonic;
import '../../utils/utils.dart' as utils;
import '../../hdkeychain/hdkeychain.dart' show MAX_SEED_BYTES, MIN_SEED_BYTES;

int checksumByte(Uint8List data) {
  var digest = SHA256Digest();
  digest.update(data, 0, data.length);
  var out = Uint8List(digest.digestSize);
  digest.doFinal(out, 0);
  digest.reset();
  digest.update(out, 0, out.length);
  digest.doFinal(out, 0);
  return out[0];
}

Uint8List mnemonicToSeed(String input) {
  var words = input.trim();
  Uint8List seed;
  var len = words.length;
  if (len == 1) {
    seed = utils.hexToBytes(words[0]);
  } else if (len > 1) {
    seed = decodeMnemonics(words);
  }
  return seed;
}
//
//String generate([int size = MIN_SEED_BYTES]) {
//  if (size < MIN_SEED_BYTES || size > MAX_SEED_BYTES) {
//    throw FormatException(
//        'seed length must be between ${MIN_SEED_BYTES * 8} and ${MAX_SEED_BYTES * 8} bits');
//  }
//  var rng = Random.secure();
//  var bytes = Uint8List(size);
//  for (var i = 0; i < size; i++) {
//    bytes[i] = rng.nextInt(0xff);
//  }
//  return seedToString(bytes);
//}
