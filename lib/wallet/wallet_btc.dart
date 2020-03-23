part of bitcoin.wallet;

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
    _manager = AddressManager(seed: seed, net: net);
    _net = net;


    _manager.putChainedAddress(utils.AddressPubKeyHash(
      hash: _manager
          .deriveKeyFromPath(0, 0, 0, true)
          .pubKeyHash,
      net: _net,
    ).encode(), 0, 0, 0);
    _manager.putChainedAddress(getAddress(0), 0, 0, 0);
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
    hdkeychain.ExtendedKey key = xpub.child(index);
    return utils.AddressScriptHash(
      scriptHash: hdkeychain.hash160(Uint8List.fromList(
          txscript.payToAddrScript(utils.AddressWitnessPubKeyHash(
        scriptHash: key.pubKeyHash,
        net: _net,
      )))),
      net: _net,
    );
  }

  String getAddress(int account) {
    var buf = _getAccountData(account);
    return _getAddressByChild(buf.albExternal.branchXpub).encode();
  }

  utils.Address newInternalAddress(int account, int poly) {
    var buf = _getAccountData(account);
    return _getAddressByChild(buf.albExternal.branchXpub);
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
      int account, utils.Amount amount, String to, bool spendAllFunds) {
    var outputs = <trans.TxOut>[];
    txhelpers.ChangeSource changeSource;

    if (spendAllFunds) {
      changeSource = txhelpers.ChangeSource(to);
    } else {
      outputs = txhelpers.makeTxOutputs(
          [txhelpers.TransactionDestination(address: to, amount: amount)]);
    }
    return _unsignedTransaction(account, outputs,
        utils.Amount(txrules.DEFAULT_RELAY_FEE_PER_KB), changeSource);
  }

  void _signTransaction(
      int account,
      trans.MsgTx tx,
      int hashType,
      Map<String, Uint8List> additionalPrevScripts,
      List<String> additionalKeysByAddress,
      Map<String, Uint8List> p2shRedeemScriptsByAddress) {
    for (var i = 0; i < tx.txIn.length; i++) {
      var txIn = tx.txIn[i];
      var key = txIn.previousOutPoint.toString();

      var prevOutScript = additionalPrevScripts.containsKey(key)
          ? additionalPrevScripts[key]
          : null;
      if (prevOutScript?.isEmpty ?? true) {
        throw FormatException('${txIn.previousOutPoint.toString()} not found');
      }

      var getKey = txscript.KeyClosure((utils.Address addr) {
        return txscript.KeyClosureResp(
            key: _manager.privateKey(addr), compressed: true);
      });

      var getScript = txscript.ScriptClosure((utils.Address addr) {
        if (additionalKeysByAddress?.isNotEmpty ?? false) {
          var address = addr.encode();
          var script = p2shRedeemScriptsByAddress[address];
          if (script?.isEmpty ?? true) {
            throw FormatException('no script for $address');
          }
          return script;
        }
        var info = _manager.fetchAddress(addr.encode());

        return txscript.payToAddrScript(utils.AddressPubKeyHash(
          hash: _manager
              .deriveKeyFromPath(info.account, info.branch, info.index, true)
              .pubKeyHash,
          net: _net,
        ));
      });

      if ((hashType & txscript.SIG_HASH_SINGLE) != txscript.SIG_HASH_SINGLE ||
          i < tx.txOut.length) {
        try {
          var script = txscript.signTxOutput(_net, tx, i, prevOutScript,
              hashType, getKey, getScript, txIn.signatureScript);

          txIn.signatureScript = script;
        } catch (e) {
          print(e);
          continue;
        }
      }
    }
  }

  String _signedTx(
      int account, trans.MsgTx unsignedTx, List<Uint8List> prevScripts) {
    var txBuf = ByteData(unsignedTx.serializeSize());
    unsignedTx.serialize(txBuf);

    var tx = trans.MsgTx.fromBytes(txBuf);

    var additionalPkScripts = <String, Uint8List>{};
    for (var i = 0; i < unsignedTx.txIn.length; i++) {
      var txi = unsignedTx.txIn[i];
      additionalPkScripts[txi.previousOutPoint.toString()] = prevScripts[i];
    }

    _signTransaction(
        account, tx, txscript.SIG_HASH_ALL, additionalPkScripts, null, null);

    txBuf = ByteData(tx.serializeSize());
    tx.serialize(txBuf);
    return utils.bytesToHex(txBuf.buffer.asUint8List());
  }

  String transaction(int account, double amount, String to,
      [spendAllFunds = false]) {
    var authoredTx =
        _constructTransaction(account, utils.Amount(amount), to, spendAllFunds);

    return _signedTx(account, authoredTx.tx, authoredTx.prevScripts);
  }
}
