library bitcoins.chaincfg;

import 'dart:typed_data';
part 'params.dart';

Params testnet3 = Params(
  name: 'testnet3',
  bech32HRPSegwit: 'tb',
  pubKeyHashAddrID: 0x6f,
  scriptHashAddrID: 0xc4,
  privateKeyID: 0xef,
  hdPrivateKeyID: Uint8List.fromList([0x04, 0x35, 0x83, 0x94]),
  hdPublicKeyID: Uint8List.fromList([0x04, 0x35, 0x87, 0xcf]),
  legacyCoinType: 1,
);

Params mainnet = Params(
  name: 'mainnet',
  bech32HRPSegwit: 'bc',
  pubKeyHashAddrID: 0x00,
  scriptHashAddrID: 0x05,
  privateKeyID: 0x80,
  hdPrivateKeyID: Uint8List.fromList([0x04, 0x88, 0xad, 0xe4]),
  hdPublicKeyID: Uint8List.fromList([0x04, 0x88, 0xb2, 0x1e]),
  legacyCoinType: 0,
);

Params _current;

/// set current network
void setNet(Params net) {
  _current = net;
}

/// get current network
Params getNet() {
  return _current ?? mainnet;
}
