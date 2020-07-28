import 'package:bitcoins/bitcoins.dart' as bitcoins;
import 'package:bitcoins/wallet/wallet.dart';
import 'package:test/test.dart';

class DAccountCache implements bitcoins.AccountCache {
  Map<String, AddressInfo> _bucket;

  @override
  AddressInfo getAddressInfo(String address) {
    var index = 0;
    var branch = 0;
    if (address == '2MxbRk54oTcntb8j1EGGAxxf8u3kFHN6kHh') {
      index = 0;
      branch = 1;
    }
    if (!(_bucket?.containsKey(address) ?? false)) {
      return AddressInfo(account: 0, branch: branch, index: index);
    }
    return _bucket[address];
  }

  @override
  bool putAddressInfo(String address, int account, int branch, int index) {
    print(
        'address: ${address}, account: ${account}, branch: ${branch}, index: ${index}');
    if ((_bucket?.containsKey(address) ?? false)) {
      return false;
    }
    index %= 1 << 32 - 1;
    var info = AddressInfo(account: account, branch: branch, index: index);

    if (_bucket?.isEmpty ?? true) {
      _bucket = <String, AddressInfo>{};
    }

    _bucket[address] = info;
    return true;
  }

  @override
  AccountProperties getAccountProperties(int account) {
    return AccountProperties();
  }
}

void main() {
  group('bitcoin test', () {
    var seed = bitcoins.mnemonicToSeed(
        'armed state jealous finish output world panic describe enact express call knee');
    var wallet = bitcoins.WalletBTC(
      seed: seed,
      net: bitcoins.testnet3,
      cache: DAccountCache(),
    );
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
    test('bitcoin transaction', () {
      wallet.from(utxos);
      print(wallet.transaction(
        0,
        BigInt.from(1000),
        wallet.getAddress(0),
        rate: 1,
//        spendAllFunds: true,
      ));
    });
  });
}
