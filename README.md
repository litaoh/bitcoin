Bitcoin witness dart implementation library 


## Usage

A simple usage example:

```dart
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

  wallet.from([
    {
      'txid':
          '1d7fab3d824356de47ec8e1821768090a1947ac2d69442c245a8c7399f71aeb4',
      'vout': 0,
      'amount': 10000 / 1e8,
      'pubKey': bitcoins.bytesToHex(bitcoins.payToAddrScript(
          bitcoins.decodeAddress('2NEbbaGpANc5ZXkEB95Uk6wHWEzAnaGudxp'))),
    }
  ]);
  print(wallet.transaction(0, 0.00001, '2NEbbaGpANc5ZXkEB95Uk6wHWEzAnaGudxp'));

  /// => 02000000000101b4ae719f39c7a845c24294d6c27a94a190807621188eec47de5643823dab7f1d000000001716001450eb5e10f7a37b20c9103a4c31bbb03657cf73f3ffffffff02e80300000000000017a914ea34fad4500cbbf1f8e0101cc24be77e588f945e87822200000000000017a9143aaac2bca12e6b94fcb44b53d6be09b9445645498702483045022100e7e75eca6d04df9d6ece260a8cbf16b43bfbe158c7ab6d13c762f33f90bd776502201c8c3e7b40b5d9331535a03401eb41ac22d8ab1ef68a32bcdff52dc43f1eebe00121034a993b7e50719f4ae05b935eff652e0a3098b645c3a7c216963e7476181ee7b600000000
}


```