part of bitcoins.wallet;

/// Account Cache interface
abstract class AccountCache {
  AddressInfo getAddressInfo(String address);

  bool putAddressInfo(String address, int account, int branch, int index);

  AccountProperties getAccountProperties(int account);
}
