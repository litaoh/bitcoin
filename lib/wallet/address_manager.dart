part of bitcoin.wallet;

const int MAX_COIN_TYPE = hdkeychain.HARDENED_KEY_START - 1; // 2^31 - 1
const int MAX_ACCOUNY_NUM = hdkeychain.HARDENED_KEY_START - 2; // 2^31 - 2
const int DEFAULT_ACCOUNT_NUM = 0;

/// ExternalBranch is the child number to use when performing BIP0044
/// style hierarchical deterministic key derivation for the external
/// branch.
const int EXTERNAL_BRANCH = 0;

/// InternalBranch is the child number to use when performing BIP0044
/// style hierarchical deterministic key derivation for the internal
/// branch.
const int INTERNAL_BRANCH = 1;

class AddressManager {
  hdkeychain.ExtendedKey _coinTypeLegacyKeyPriv;
  Map<String, ECPrivateKey> _returnedPrivKeys;

  chaincfg.Params _net;

  AccountStorage _accountStorage;

  AddressManager(
      {Uint8List seed, chaincfg.Params net, AccountStorage accountStorage}) {
    _net = net;
    _accountStorage = accountStorage ?? AccountCache();
    _init(seed);
  }
  void _init(Uint8List seed) {
    var root = hdkeychain.ExtendedKey.fromSeed(seed);
    _coinTypeLegacyKeyPriv = _deriveCoinTypeKey(root, _net.legacyCoinType);
  }

  bool putChainedAddress(String address, int account, int branch, int index) {
    return _accountStorage.putAddressInfo(address, account, branch, index);
  }

  AddressInfo fetchAddress(String address) {
    return _accountStorage.getAddressInfo(address);
  }

  AccountProperties getAccountProperties(int account) {
    return _accountStorage.getAccountProperties(account) ?? AccountProperties();
  }

  hdkeychain.ExtendedKey deriveKeyFromPath(
      int account, int branch, int index, bool isPrivate) {
    var accKey = getAccountKey(account);

    if (!isPrivate) {
      accKey = accKey.neuter();
    }

    return accKey.child(branch).child(index);
  }

  ECPrivateKey privateKey(utils.Address addr) {
    var address = addr.encode();
    if (_returnedPrivKeys?.isEmpty ?? true) {
      _returnedPrivKeys = Map();
    }

    if (_returnedPrivKeys.containsKey(address)) {
      return _returnedPrivKeys[address];
    }

    var info = fetchAddress(address);

    var xpriv = deriveKeyFromPath(info.account, info.branch, info.index, true);

    var key = xpriv.ECPrivKey();
    _returnedPrivKeys[address] = key;
    return key;
  }

  hdkeychain.ExtendedKey getAccountKey(int account) {
    var acctKeyLegacyPriv = _deriveAccountKey(_coinTypeLegacyKeyPriv, account);
    return acctKeyLegacyPriv;
  }
}

hdkeychain.ExtendedKey _deriveAccountKey(
    hdkeychain.ExtendedKey coinTypeKey, int account) {
  /// Enforce maximum account number.
  if (account > MAX_ACCOUNY_NUM) {
    throw FormatException('account ${account}');
  }

  /// Derive the account key as a child of the coin type key.
  return coinTypeKey.child(account + hdkeychain.HARDENED_KEY_START);
}

hdkeychain.ExtendedKey _deriveCoinTypeKey(
    hdkeychain.ExtendedKey masterNode, int coinType) {
  if (coinType > MAX_COIN_TYPE) {
    throw FormatException('coin type ${coinType}');
  }
  var purpose = masterNode.child(49 + hdkeychain.HARDENED_KEY_START);
  var coinTypeKey = purpose.child(coinType + hdkeychain.HARDENED_KEY_START);
  return coinTypeKey;
}
