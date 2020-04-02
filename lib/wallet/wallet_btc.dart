part of bitcoins.wallet;

const int DEFAULT_GAP_LIMIT = 20;

const int GAP_POLICY_ERROR = 0;
const int GAP_POLICY_IGNORE = 1;
const int GAP_POLICY_WRAP = 2;

class WalletBTC {
  AddressManager _manager;
  chaincfg.Params _net;
  final Map<int, AccountData> _accountData = <int, AccountData>{};

  trans.Store _store;

  WalletBTC({Uint8List seed, chaincfg.Params net}) {
    chaincfg.setNet(net);
    _manager = AddressManager(seed: seed, net: net);
    _net = net;
    _store = trans.Store();
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

  String getAddress(int account) {
    var buf = _getAccountData(account);
    return _getAddressByChild(buf.albExternal.branchXpub).encode();
  }

  utils.Address newInternalAddress(int account) {
    var buf = _getAccountData(account);

    var addr = _getAddressByChild(buf.albExternal.branchXpub);

    _manager.putChainedAddress(addr.encode(), account, 0, 0);
    return addr;
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
        pubKey:
            txscript.payToAddrScript(utils.decodeAddress(utxos[i]['address'])),
      );
    }
    return this;
  }

  trans.AuthoredTx _unsignedTransaction(
      int account, List<trans.TxOut> outputs, utils.Amount relayFeePerKb,
      [txhelpers.ChangeSource changeSource]) {
    var sourceImpl = _store.makeInputSource();

    Function inputSource = sourceImpl.selectInputs;

    changeSource ??=
        txhelpers.P2PKHChangeSource(account: account, wallet: this);

    return trans.unsignedTransaction(
        outputs, relayFeePerKb, inputSource, changeSource);
  }

  trans.AuthoredTx _constructTransaction(
      int account, utils.Amount amount, String to, { bool spendAllFunds, int rate } ) {
    var outputs = <trans.TxOut>[];
    txhelpers.ChangeSource changeSource;

    if (spendAllFunds) {
      changeSource = txhelpers.ChangeSource(to);
    } else {
      outputs = txhelpers.makeTxOutputs(
          [txhelpers.TransactionDestination(address: to, amount: amount)]);
    }
    utils.Amount fee;
    if(rate != null){
      fee = utils.Amount.fromUnit(BigInt.from(rate * 1e3));
    }
    fee ??= utils.Amount(txrules.DEFAULT_RELAY_FEE_PER_KB);
    return _unsignedTransaction(account, outputs, fee, changeSource);
  }

  String transaction(int account, double amount, String to,
      { spendAllFunds = false, int rate }) {
    var authoredTx =
        _constructTransaction(account, utils.Amount(amount), to, spendAllFunds: spendAllFunds, rate: rate);

    var getKey = txscript.KeyClosure((utils.Address addr) {
      return txscript.KeyClosureResp(
          key: _manager.privateKey(addr), compressed: true);
    });

    var getScript = txscript.ScriptClosure((utils.Address addr) {
      var info = _manager.fetchAddress(addr.encode());

      return _manager
          .deriveKeyFromPath(info.account, info.branch, info.index, true)
          .pubKeyHash;
    });
    trans.addAllInputScripts(authoredTx.tx, authoredTx.prevScripts,
        authoredTx.inputValues, _net, getKey, getScript);

    var txBuf = ByteData(authoredTx.tx.serializeSize());
    authoredTx.tx.serialize(txBuf);
    return utils.bytesToHex(txBuf.buffer.asUint8List());
//    return _signedTx(account, authoredTx.tx, authoredTx.prevScripts);
  }
}
