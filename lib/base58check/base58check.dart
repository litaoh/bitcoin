library base58check;

import 'package:bs58/bs58.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart' show ListEquality;
import '../chainhash/chainhash.dart' as chainhash;

class Base58CheckCodec extends Codec<Uint8List, String> {
  final Base58CheckEncoder _encoder;
  final Base58CheckDecoder _decoder;

  Base58CheckCodec()
      : _encoder = Base58CheckEncoder(),
        _decoder = Base58CheckDecoder();
  @override
  Converter<Uint8List, String> get encoder => _encoder;

  @override
  Converter<String, Uint8List> get decoder => _decoder;
}

class Base58CheckEncoder extends Converter<Uint8List, String> {
  const Base58CheckEncoder();

  @override
  String convert(Uint8List payload) {
    var bytes = Uint8List(payload.length + 4);

    bytes.setRange(0, payload.length, payload);

    var checksum = _hash(bytes.sublist(0, bytes.length - 4));
    bytes.setRange(bytes.length - 4, bytes.length, checksum.getRange(0, 4));
    return base58.encode(bytes);
  }
}

Uint8List _hash(Uint8List b) => chainhash.hashB(chainhash.hashB(b));

class Base58CheckDecoder extends Converter<String, Uint8List> {
  const Base58CheckDecoder();
  @override
  Uint8List convert(String encoded) => _convert(encoded, true);

  Uint8List convertUnchecked(String encoded) => _convert(encoded, true);

  Uint8List _convert(String encoded, bool validateChecksum) {
    var bytes = base58.decode(encoded);
    if (bytes.length < 6) {
      throw FormatException(
          'Invalid Base58Check encoded string: must be at least size 6');
    }
    var checksum = _hash(bytes.sublist(0, bytes.length - 4));
    var providedChecksum = bytes.sublist(bytes.length - 4, bytes.length);
    if (validateChecksum &&
        !ListEquality().equals(providedChecksum, checksum.sublist(0, 4))) {
      throw FormatException('Invalid checksum in Base58Check encoding.');
    }
    return Uint8List.fromList(bytes.sublist(0, bytes.length - 4));
  }
}
