import 'package:bitcoin/bitcoin.dart' as demos;
import 'package:bitcoin/wallet/seed/seed.dart' as seed;
import 'dart:typed_data';
import 'package:test/test.dart';

void main() {
  group('demos', () {
    demos.setNet(demos.testnet3);
    Uint8List a = seed.mnemonicToSeed(
        'disagree able panda slam process include client ghost cotton ribbon toilet spell');
    var wallet = demos.WalletBTC(seed: a, net: demos.testnet3);
    print(wallet.getAddress(0));
    wallet.from([
      {
        'txid':
            '8bfa8f66b229d91ce057e4fa7dcb26510b1d11316f8e5aa1cf1e111f0c2767ba',
        'vout': 1,
        'amount': 10000000 / 1e8,
        'scriptPubKey': demos.bytesToHex(demos
            .decodeAddress('2NBDEbsoYte4bnxDXhQqA46y31mQjy9D226')
            .hash160())
      }
    ]);
//    wallet.transaction(0, 10000 / 1e8, '2NBDEbsoYte4bnxDXhQqA46y31mQjy9D226');
  });
}
