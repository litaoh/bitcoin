import 'package:bitcoins/bitcoins.dart' as bitcoins;
import 'package:test/test.dart';

void main() {
  group('bitcoin test', () {
    var seed =
        '590b81b6bf51754e3907514801149d23578b58fcb5de3877e6d156e2388843a0a0740c4179e2dfa9d0ef99d36a262737141ad2685b1beb79d0de9ae9cc884381';

    test('gen mnemonic', () {
      expect(12, bitcoins.generateMnemonic().split(' ').length);
    });
    test('mnemonic to seed', () {
      expect(
          seed,
          bitcoins.bytesToHex(bitcoins.mnemonicToSeed(
              'chase toss tongue laugh circle health income mechanic art ranch message pencil')));
    });
    var wallet = bitcoins.WalletBTC(
        seed: bitcoins.mnemonicToSeed(seed), net: bitcoins.mainnet);
    test('get address', () {
      expect('367PbfsCkFvHrCK1ZC3Lo3xaEGdssrZGF3', wallet.getAddress(0));
    });

    test('bitcoin transaction', () {
      wallet.from([
        {
          'txid':
              '8bfa8f66b229d91ce057e4fa7dcb26510b1d11316f8e5aa1cf1e111f0c2767ba',
          'vout': 0,
          'amount': 100000 / 1e8,
          'address': '367PbfsCkFvHrCK1ZC3Lo3xaEGdssrZGF3'
        }
      ]);
      expect(
          '02000000000101ba67270c1f111ecfa15a8e6f31111d0b5126cb7dfae457e01cd'
          '929b2668ffa8b0000000017160014fb9fb211925754b81df37b3d9b75677f5eb3609'
          'fffffffff02102700000000000017a914307c944aeaa6b12b0e968434c408292f10a'
          '7a36587eb5e01000000000017a914307c944aeaa6b12b0e968434c408292f10a7a36'
          '587024830450221009c4599edfaa33dbec1269de382bf0ea91c33503bc819b094a66'
          'd7d2c7767d0b00220628d613d45ebd6ed800f516bae3814a6c8c85138dad3a31acc8'
          '709b8d04b00a1012102ea59d8804676a8bef95c4cb0df09d15c537da91598b6c206b'
          '9e80b9be9a8675d00000000',
          wallet.transaction(0, 0.0001, '367PbfsCkFvHrCK1ZC3Lo3xaEGdssrZGF3'));
    });
  });
}
