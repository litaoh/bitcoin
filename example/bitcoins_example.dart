import 'package:bitcoins/bitcoins.dart' as bitcoins;

void main() {
  var seed =
      '590b81b6bf51754e3907514801149d23578b58fcb5de3877e6d156e2388843a0a0740c4179e2dfa9d0ef99d36a262737141ad2685b1beb79d0de9ae9cc884381';
  var wallet = bitcoins.WalletBTC(
      seed: bitcoins.mnemonicToSeed(seed), net: bitcoins.mainnet);
  print(wallet.getAddress(0));

  /// => 3QuYJkUFjMBSdPMAC4cmKeEgeSpPBtCA4X
  wallet.from([
    {
      'txid':
          '8bfa8f66b229d91ce057e4fa7dcb26510b1d11316f8e5aa1cf1e111f0c2767ba',
      'vout': 0,
      'amount': 100000 / 1e8,
      'address': '3QuYJkUFjMBSdPMAC4cmKeEgeSpPBtCA4X'
    }
  ]);
  print(wallet.transaction(0, 0.0001, '3QuYJkUFjMBSdPMAC4cmKeEgeSpPBtCA4X'));

  /// => 02000000000101ba67270c1f111ecfa15a8e6f31111d0b5126cb7dfae457e01cd929b2668ffa8b000000001716001451f9c851ba48df6ebfc8e5c6e98d5bd1d21ee6d6ffffffff02102700000000000017a914fea93f35a351a9385a1a4cc6a0a5813e30065be387eb5e01000000000017a914fea93f35a351a9385a1a4cc6a0a5813e30065be38702483045022100f477f50b98178b6bc5f4545eeb0c59a0f58afc1570c4312c03f44f8f5b4769bb0220009dd5d888b72b061fe0deec7acc1aea949e667697219b33373db2d303b51dea0121029939e358d7e2c233421760f39f8cb9985e8893de44e59f3e94bf055dfaa3302900000000
}
