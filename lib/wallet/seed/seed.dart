library bitcoins.wallet.seed;

import 'dart:math';
import 'dart:typed_data';

import 'package:bitcoins/hdkeychain/hdkeychain.dart'
    show MAX_SEED_BYTES, MIN_SEED_BYTES;
import 'package:pointycastle/export.dart' show SHA256Digest;

import '../../pgpwordlist/pgpwordlist.dart';
import '../../utils/utils.dart' as utils;

/// checksum
String _checksumByte(Uint8List data) {
  var digest = SHA256Digest();
  digest.update(data, 0, data.length);
  var out = Uint8List(digest.digestSize);
  digest.doFinal(out, 0);
  var end = data.length * 8 ~/ 32;
  return _bytesToBinary(Uint8List.fromList(out)).substring(0, end);
}

/// mnemonic to Seed
Uint8List mnemonicToSeed(String input) {
  var words = input.trim();
  Uint8List seed;
  var len = words.length;
  if (len == 1) {
    seed = utils.hexToBytes(words);
  } else if (len > 1) {
    seed = decodeMnemonics(words);
  }
  return seed;
}

/// binary to byte
int _binaryToByte(String binary) {
  return int.parse(binary, radix: 2);
}

/// byte to binary
String _bytesToBinary(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('');
}

/// generate mnemonic
String generateMnemonic([int size = 16]) {
  if (size < MIN_SEED_BYTES || size > MAX_SEED_BYTES) {
    throw FormatException(
        'seed length must be between ${MIN_SEED_BYTES * 8} and ${MAX_SEED_BYTES * 8} bits');
  }
  var rng = Random.secure();
  var bytes = Uint8List(size);
  for (var i = 0; i < size; i++) {
    bytes[i] = rng.nextInt(0xff);
  }

  var bits = _bytesToBinary(bytes) + _checksumByte(bytes);

  var regex = RegExp(r'.{1,11}', caseSensitive: false, multiLine: false);
  var chunks = regex
      .allMatches(bits)
      .map((match) => match.group(0))
      .toList(growable: false);
  return chunks.map((String word) {
    return WordList[_binaryToByte(word)];
  }).join(' ');
}
