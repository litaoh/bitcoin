part of bitcoins.wallet;

abstract class AccountCache {
  AddressInfo getAddressInfo(String address);

  bool putAddressInfo(String address, int account, int branch, int index);

  AccountProperties getAccountProperties(int account);
}
