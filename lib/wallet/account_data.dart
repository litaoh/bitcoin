part of bitcoins.wallet;

/// Account Data
class AccountData {
  final hdkeychain.ExtendedKey xpub;
  final AddressBuffer albExternal;
  final AddressBuffer albInternal;

  AccountData({this.xpub, this.albExternal, this.albInternal});
}
