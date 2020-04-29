import 'package:bitcoins/bitcoins.dart' as bitcoins;
import 'package:bitcoins/wallet/wallet.dart';
import 'package:test/test.dart';

class AccountCache implements AccountStorage {
  Map<String, AddressInfo> _bucket;

  AccountCache();

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
    print('address: ${address}, account: ${account}, branch: ${branch}, index: ${index}');
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
      multipleAddress: true,
      accountStorage: AccountCache(),
    );

    var utxos = <Map<String, dynamic>>[
      {
        'txid':
            '1d7fab3d824356de47ec8e1821768090a1947ac2d69442c245a8c7399f71aeb4',
        'vout': 0,
        'amount': 0.01309512,
        'pubKey': bitcoins.bytesToHex(bitcoins.payToAddrScript(bitcoins.decodeAddress('2MxbRk54oTcntb8j1EGGAxxf8u3kFHN6kHh'))),
      }
    ];
    test('bitcoin transaction', () {
      wallet.from(utxos);
      print(wallet.transaction(
        0,
        0.0001,
        '2NEbbaGpANc5ZXkEB95Uk6wHWEzAnaGudxp',
        rate: 1,
      ));
    });
  });
}
