import 'package:bitcoin/bitcoin.dart' as demos;
import 'package:bitcoin/wallet/seed/seed.dart' as seed;
import 'dart:typed_data';
import 'package:test/test.dart';

void main() {
  group('bitcoin', () {
    demos.setNet(demos.testnet3);
    Uint8List a = seed.mnemonicToSeed(
        'disagree able panda slam process include client ghost cotton ribbon toilet spell');
    var wallet = demos.WalletBTC(seed: a, net: demos.testnet3);
    print(wallet.getAddress(0));
    wallet.from([
      {
        'txid':
            'f8b49d7c12d0d7e42d5740015ecd24a94da4ab7f957052ac82a9987fd0b740ac',
        'vout': 0,
        'amount': 0.001,
        'address': '2NBDEbsoYte4bnxDXhQqA46y31mQjy9D226'
      }
    ]);
    print(wallet.transaction(0, 0.0001, '2NBDEbsoYte4bnxDXhQqA46y31mQjy9D226'));
  });
}
