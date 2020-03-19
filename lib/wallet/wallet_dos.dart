part of bitcoin.wallet;

class WalletBTC {
  AddressManager _manager;
  chaincfg.Params _net;
  final Map<int, AccountData> _accountData = <int, AccountData>{};

  trans.Store _store;

  WalletBTC({Uint8List seed, chaincfg.Params net}) {
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

    var data = _deriveBranches(pub);

    var buf = AccountData(
        xpub: pub,
        albExternal: AddressBuffer(
            branchXpub: data[0],
            lastUsed: pops.lastUsedExternalIndex ?? 0,
            cursor: pops.lastReturnedExternalIndex ?? 0),
        albInternal: AddressBuffer(
            branchXpub: data[1],
            lastUsed: pops.lastUsedInternalIndex ?? 0,
            cursor: pops.lastReturnedInternalIndex ?? 0));

    _accountData[account] = buf;

    return buf;
  }

  utils.Address _getAddressByChild(hdkeychain.ExtendedKey xpub,
      [int index = 0]) {
    hdkeychain.ExtendedKey key = xpub.child(index);
    var pkHash = key.pubKeyHash;
    var pkBytes = pkHash.toList(growable: true);
    pkBytes.insert(0, 0x14);
    pkBytes.insert(0, 0x00);
    pkHash = hdkeychain.hash160(Uint8List.fromList(pkBytes));
    return utils.AddressScriptHash(scriptHash: pkHash, net: _net);
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
          pubKey: utils.hexToBytes(utxos[i]['scriptPubKey']),
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

  List<Map<String, String>> _signTransaction(
      int account,
      trans.MsgTx tx,
      int hashType,
      Map<String, Uint8List> additionalPrevScripts,
      List<String> additionalKeysByAddress,
      Map<String, Uint8List> p2shRedeemScriptsByAddress) {
    var signErrors = <Map<String, String>>[];
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
        return addr.scriptAddress();
      });

      if ((hashType & txscript.SIG_HASH_SINGLE) != txscript.SIG_HASH_SINGLE ||
          i < tx.txOut.length) {
        try {
          var script = txscript.signTxOutput(_net, tx, i, prevOutScript,
              hashType, getKey, getScript, txIn.signatureScript);

          txIn.signatureScript = script;
        } catch (e) {
          signErrors.add(<String, String>{
            'inputIndex': i.toString(),
            'error': e.toString()
          });
          continue;
        }
      }

      try {
        var vm = txscript.Engine(
            scriptPubKey: prevOutScript,
            tx: tx,
            txIdx: i,
            flags: 15,
            scriptVersion: txscript.DEFAULT_SCRIPT_VERSION);
        vm.execute();
      } catch (e) {
        signErrors.add(<String, String>{
          'inputIndex': i.toString(),
          'error': e.toString()
        });
      }
    }
    return signErrors;
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
