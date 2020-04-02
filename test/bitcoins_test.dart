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
      expect('3QuYJkUFjMBSdPMAC4cmKeEgeSpPBtCA4X', wallet.getAddress(0));
    });

    test('bitcoin transaction', () {
      wallet.from([
        {
          'txid':
              '8bfa8f66b229d91ce057e4fa7dcb26510b1d11316f8e5aa1cf1e111f0c2767ba',
          'vout': 0,
          'amount': 100000 / 1e8,
          'address': '3QuYJkUFjMBSdPMAC4cmKeEgeSpPBtCA4X'
        }
      ]);
      expect(
              '02000000000101ba67270c1f111ecfa15a8e6f31111d0b5126cb7dfae457e01cd929b2668ffa8b000000001716001451f9c851ba48df6ebfc8e5c6e98d5bd1d21ee6d6ffffffff011a8601000000000017a914fea93f35a351a9385a1a4cc6a0a5813e30065be38702483045022100b5e6b181b5179ba986a1cda4ca00d58172921acf37445b8d2105179660763ce3022026ad4fe7ae7d21ab2ab68b70fbe6bb10db0d6af29090d795b8c2c3642dacd0110121029939e358d7e2c233421760f39f8cb9985e8893de44e59f3e94bf055dfaa3302900000000',
          wallet.transaction(0, 0.0001, '3QuYJkUFjMBSdPMAC4cmKeEgeSpPBtCA4X', spendAllFunds: true,rate: 1));
    });
  });
}
