part of bitcoins.wallet;

/// DefaultAccountCache
class DefaultAccountCache implements AccountCache {
  Map<String, AddressInfo> _bucket;

  @override
  AddressInfo getAddressInfo(String address) {
    if (!(_bucket?.containsKey(address) ?? false)) {
      return AddressInfo(account: 0, branch: 0, index: 0);
//      throw FormatException('no address with hash $address');
    }
    return _bucket[address];
  }

  @override
  bool putAddressInfo(String address, int account, int branch, int index) {
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
