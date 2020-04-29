part of bitcoins.wallet;

const int DEFAULT_GAP_LIMIT = 20;

const int GAP_POLICY_ERROR = 0;
const int GAP_POLICY_IGNORE = 1;
const int GAP_POLICY_WRAP = 2;

typedef _PersistReturned = void Function(
  utils.Address,
  int account,
  int branch,
  int index,
);

class WalletBTC {
  AddressManager _manager;
  chaincfg.Params _net;
  final Map<int, AccountData> _accountData = <int, AccountData>{};

  trans.Store _store;
  bool _multipleAddress;
  bool _addressReuse;
  int _gapLimit;

  WalletBTC({
    Uint8List seed,
    chaincfg.Params net,
    bool multipleAddress,
    bool addressReuse,
    int gapLimit = 20,
    AccountStorage accountStorage,
  }) {
    _manager = AddressManager(
      seed: seed,
      net: net,
      accountStorage: accountStorage,
    );
    _net = net;
    _store = trans.Store();
    _multipleAddress = multipleAddress ?? false;
    _addressReuse = addressReuse ?? false;
    assert(gapLimit > 0);
    _gapLimit = gapLimit;
  }

  AccountData _getAccountData(int account) {
    if (_accountData.containsKey(account)) {
      return _accountData[account];
    }
    var pops = _manager.getAccountProperties(account);
    var pub = _manager.getAccountKey(account);

    var buf = AccountData(
      xpub: pub,
      albExternal: AddressBuffer(
        branchXpub: pub.child(EXTERNAL_BRANCH),
        lastUsed: pops.lastUsedExternalIndex ?? 0,
        cursor: pops.lastReturnedExternalIndex ?? 0,
      ),
      albInternal: AddressBuffer(
        branchXpub: pub.child(INTERNAL_BRANCH),
        lastUsed: pops.lastUsedInternalIndex ?? 0,
        cursor: pops.lastReturnedInternalIndex ?? 0,
      ),
    );

    _accountData[account] = buf;

    return buf;
  }

  utils.Address _getAddressByChild(hdkeychain.ExtendedKey xpub,
      [int index = 0]) {
    var key = xpub.child(index);
    return utils.AddressScriptHash(
      scriptHash: hdkeychain.hash160(Uint8List.fromList(
          txscript.payToAddrScript(utils.AddressWitnessPubKeyHash(
        hash: key.pubKeyHash,
        net: _net,
      )))),
      net: _net,
    );
  }

  String getPubKey(int account) {
    var pub = _manager.getAccountKey(account);
    return pub.toBase58(_net.hdPublicKeyID);
  }

  String getAddress(int account) {
    var buf = _getAccountData(account);
    return _getAddressByChild(buf.albExternal.branchXpub).encode();
  }

  utils.Address _nextAddress(
      int account, int branch, _PersistReturned persist) {
    var buf = _getAccountData(account);
    if (buf == null) {
      throw FormatException('no account ${account}');
    }
    var alb;
    switch (branch) {
      case EXTERNAL_BRANCH:
        alb = buf.albExternal;
        break;
      case INTERNAL_BRANCH:
        alb = buf.albInternal;
        break;
      default:
        throw FormatException('invalid branch=${branch}');
        break;
    }
    if (_addressReuse && alb.cursor >= _gapLimit) {
      alb.cursor = 0;
    }

    var childIndex = alb.lastUsed + alb.cursor;
    if (childIndex >= hdkeychain.HARDENED_KEY_START) {
      throw FormatException('account $account branch $branch exhausted');
    }

    var child = alb.branchXpub.child(childIndex);

    var addr = utils.AddressScriptHash(
      scriptHash: hdkeychain.hash160(Uint8List.fromList(
          txscript.payToAddrScript(utils.AddressWitnessPubKeyHash(
            hash: child.pubKeyHash,
            net: _net,
          )))),
      net: _net,
    );

    persist(addr, account, branch, childIndex);

    if (_multipleAddress) {
      alb.cursor++;
    }

    return addr;
  }

  void _persistReturnedChild(
    utils.Address addr,
    int account,
    int branch,
    int index,
  ) {
    _manager.putChainedAddress(addr.encode(), account, branch, index);
  }

  utils.Address newExternalAddress(int account) {
    return _nextAddress(account, EXTERNAL_BRANCH, _persistReturnedChild);
  }

  utils.Address newInternalAddress(int account) {
    return _nextAddress(account, INTERNAL_BRANCH, _persistReturnedChild);
  }

  WalletBTC from(List<Map<String, dynamic>> utxos) {
    if (utxos?.isEmpty ?? true) {
      throw FormatException('Utxos is Empty.');
    }

    for (var i = 0; i < utxos.length; i++) {
      _store.put(
        txid: chainhash.Hash.fromString(utxos[i]['txid']),
        vout: utxos[i]['vout'],
        amount: utils.Amount(double.parse(utxos[i]['amount'].toString())),
        pubKey: utils.hexToBytes(utxos[i]['pubKey']),
      );
    }
    return this;
  }

  trans.AuthoredTx _unsignedTransaction(
    int account,
    List<trans.TxOut> outputs,
    utils.Amount relayFeePerKb, [
    txhelpers.ChangeSource changeSource,
  ]) {
    var sourceImpl = _store.makeInputSource();

    Function inputSource = sourceImpl.selectInputs;

    changeSource ??= txhelpers.P2PKHChangeSource(
      account: account,
      wallet: this,
    );

    return trans.unsignedTransaction(
      outputs,
      relayFeePerKb,
      inputSource,
      changeSource,
    );
  }

  trans.AuthoredTx _constructTransaction(
    int account,
    utils.Amount amount,
    utils.Address to, {
    bool spendAllFunds,
    int rate,
  }) {
    var outputs = <trans.TxOut>[];
    txhelpers.ChangeSource changeSource;

    if (spendAllFunds) {
      changeSource = txhelpers.ChangeSource(to);
    } else {
      outputs = txhelpers.makeTxOutputs([
        txhelpers.TransactionDestination(
          address: to,
          amount: amount,
        )
      ]);
    }
    utils.Amount fee;
    if (rate != null) {
      fee = utils.Amount.fromUnit(BigInt.from(rate * 1e3));
    }
    fee ??= utils.Amount(txrules.DEFAULT_RELAY_FEE_PER_KB);
    return _unsignedTransaction(
      account,
      outputs,
      fee,
      changeSource,
    );
  }

  String transaction(
    int account,
    double amount,
    String to, {
    spendAllFunds = false,
    int rate,
  }) {
    var addr = utils.decodeAddress(to);
    if (!addr.isForNet(_net)) {
      throw FormatException('Address does not match environment');
    }
    var authoredTx = _constructTransaction(
      account,
      utils.Amount(amount),
      addr,
      spendAllFunds: spendAllFunds,
      rate: rate,
    );

    var getKey = txscript.KeyClosure((utils.Address addr) {
      return txscript.KeyClosureResp(
        key: _manager.privateKey(addr),
        compressed: true,
      );
    });

    var getScript = txscript.ScriptClosure((utils.Address addr) {
      var info = _manager.fetchAddress(addr.encode());

      return _manager
          .deriveKeyFromPath(
            info.account,
            info.branch,
            info.index,
            true,
          )
          .pubKeyHash;
    });
    trans.addAllInputScripts(
      authoredTx.tx,
      authoredTx.prevScripts,
      authoredTx.inputValues,
      _net,
      getKey,
      getScript,
    );

    var txBuf = ByteData(authoredTx.tx.serializeSize());
    authoredTx.tx.serialize(txBuf);
    return utils.bytesToHex(txBuf.buffer.asUint8List());
//    return _signedTx(account, authoredTx.tx, authoredTx.prevScripts);
  }
}
