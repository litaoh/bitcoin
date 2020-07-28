import 'package:bitcoins/bitcoins.dart' as bitcoins;

void main() {
  var mn =
      'armed state jealous finish output world panic describe enact express call knee';
  var wallet = bitcoins.WalletBTC(
    seed: bitcoins.mnemonicToSeed(mn),
    net: bitcoins.testnet3,
  );
  print(wallet.getAddress(0));

  /// => 2NEbbaGpANc5ZXkEB95Uk6wHWEzAnaGudxp

  var pubKey = bitcoins.bytesToHex(
      bitcoins.payToAddrScript(bitcoins.decodeAddress(wallet.getAddress(0))));
  var utxos = <bitcoins.Utxo>[
    bitcoins.Utxo.fromJSON({
      'txid':
          'baded643974a04a48c36c0e2721379a83075061fb8c28aaf9549f90f972d4d71',
      'vout': 0,
      'amount': 10000,
      'pubKey': pubKey
    })
  ];
  wallet.from(utxos);
  print(wallet.transaction(
      0, BigInt.from(1000), '2NEbbaGpANc5ZXkEB95Uk6wHWEzAnaGudxp'));

  /// => 02000000000101714d2d970ff94995af8ac2b81f067530a8791372e2c0368ca4044a9743d6deba000000001716001450eb5e10f7a37b20c9103a4c31bbb03657cf73f3ffffffff02e80300000000000017a914ea34fad4500cbbf1f8e0101cc24be77e588f945e87822200000000000017a914ea34fad4500cbbf1f8e0101cc24be77e588f945e8702483045022100a9bd79e71aa5cae58e9a95af760839fe48b81299d9469ef296ef370bb8ee0d29022027405fb29106e47dee97f321fb7afafd3f60ae27b4de95b7642b01f9e32286320121034a993b7e50719f4ae05b935eff652e0a3098b645c3a7c216963e7476181ee7b600000000
}
