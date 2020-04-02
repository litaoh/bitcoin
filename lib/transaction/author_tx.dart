part of bitcoins.transaction;

/// GENERATED_TX_VERSION is the version of the transaction being generated.
/// It is defined as a constant here rather than using the wire.TxVersion
/// constant since a change in the transaction version will potentially
/// require changes to the generated transaction.  Thus, using the wire
/// constant for the generated transaction version could allow creation
/// of invalid transactions for the updated version.
const int GENERATED_TX_VERSION = 2;

class AuthoredTx {
  MsgTx tx;
  List<Uint8List> prevScripts;
  utils.Amount totalInput;
  List<utils.Amount> inputValues;
  int changeIndex;
  int estimatedSignedSerializeSize;
  AuthoredTx(
      {this.tx,
      this.prevScripts,
      this.totalInput,
      this.changeIndex,
      this.inputValues,
      this.estimatedSignedSerializeSize});
}

/// creates an unsigned transaction paying to one or more
/// non-change outputs.  An appropriate transaction fee is included based on the
/// transaction size.
///
/// Transaction inputs are chosen from repeated calls to fetchInputs with
/// increasing targets amounts.
///
/// If any remaining output value can be returned to the walletdos via a change
/// output without violating mempool dust rules, a P2PKH change output is
/// appended to the transaction outputs.  Since the change output may not be
/// necessary, fetchChange is called zero or one times to generate this script.
/// This function must return a P2PKH script or smaller, otherwise fee estimation
/// will be incorrect.
///
/// If successful, the transaction, total input value spent, and all previous
/// output scripts are returned.  If the input source was unable to provide
/// enough input value to pay for every output any any necessary fees, an
/// InputSourceError is returned.
AuthoredTx unsignedTransaction(List<TxOut> outputs, utils.Amount relayFeePerKb,
    Function fetchInputs, txhelpers.ChangeSource fetchChange) {
  var targetAmount = helpers.sumOutputValues(outputs);

  var estimatedSize = txsizes.estimateVirtualSize(0, 1, 0, outputs, true);
  var targetFee = txrules.feeForSerializeSize(relayFeePerKb, estimatedSize);
  while (true) {
    InputDetail inputDetail = fetchInputs(
        utils.Amount.fromUnit(targetAmount.toCoin() + targetFee.toCoin()));
    if (inputDetail.amount.toCoin() <
        targetAmount.toCoin() + targetFee.toCoin()) {
      throw FormatException('insufficient balance');
    }

    var nested = 0, p2wpkh = 0, p2pkh = 0;
    for (var i = 0; i < inputDetail.scripts.length; i++) {
      var pkScript = inputDetail.scripts[i];
      if (txscript.isPayToScriptHash(pkScript)) {
        nested++;
      } else if (txscript.isPayToWitnessPubKeyHash(pkScript)) {
        p2wpkh++;
      } else {
        p2pkh++;
      }
    }

    var maxSignedSize =
        txsizes.estimateVirtualSize(p2pkh, p2wpkh, nested, outputs, true);
    var maxRequiredFee =
        txrules.feeForSerializeSize(relayFeePerKb, maxSignedSize);
    var remainingAmount = inputDetail.amount.toCoin() - targetAmount.toCoin();
    if (remainingAmount < maxRequiredFee.toCoin()) {
      targetFee = maxRequiredFee;
      continue;
    }

    var unsignedTransaction = MsgTx(
      version: GENERATED_TX_VERSION,
      txIn: inputDetail.inputs,
      txOut: outputs,
      lockTime: 0,
    );
    var changeAmount = inputDetail.amount.toCoin() -
        targetAmount.toCoin() -
        maxRequiredFee.toCoin();

    if (changeAmount != BigInt.zero &&
        !txrules.isDustAmount(utils.Amount.fromUnit(changeAmount), utils.Amount(txrules.DEFAULT_RELAY_FEE_PER_KB))) {
      fetchChange.script();
      var changeScript = fetchChange.hash;

      var change = TxOut(
        value: utils.Amount.fromUnit(changeAmount),
        pkScript: changeScript,
      );
      outputs.add(change);
    }

    return AuthoredTx(
      tx: unsignedTransaction,
      inputValues: inputDetail.inputValues,
      prevScripts: inputDetail.scripts,
      totalInput: inputDetail.amount,
    );
  }
}

/// _spendWitnessKeyHash generates, and sets a valid witness for spending the
/// passed pkScript with the specified input amount. The input amount *must*
/// correspond to the output value of the previous pkScript, or else verification
/// will fail since the new sighash digest algorithm defined in BIP0143 includes
/// the input value in the sighash.
void _spendWitnessKeyHash(
    TxIn txIn,
    Uint8List pkScript,
    utils.Amount inputValue,
    chaincfg.Params net,
    txscript.KeyClosure kdb,
    txscript.ScriptClosure sdb,
    MsgTx tx,
    txscript.TxSigHashes hashCache,
    int idx) {
  var data = txscript.extractPkScriptAddrs(pkScript, net);
  List<utils.Address> addrs = data[1];
  var resp = kdb.getKey(addrs[0]);

  var pubKeyHash = sdb.getScript(addrs[0]);
  var p2wkhAddr = utils.AddressWitnessPubKeyHash(hash: pubKeyHash, net: net);

  var witnessProgram = txscript.payToAddrScript(p2wkhAddr);

  var witnessScript = txscript.witnessSignature(tx, hashCache, idx, inputValue,
      witnessProgram, txscript.SIG_HASH_ALL, resp.key, true);

  txIn.witness = witnessScript;
}

/// _spendNestedWitnessPubKey generates both a sigScript, and valid witness for
/// spending the passed pkScript with the specified input amount. The generated
/// sigScript is the version 0 p2wkh witness program corresponding to the queried
/// key. The witness stack is identical to that of one which spends a regular
/// p2wkh output. The input amount *must* correspond to the output value of the
/// previous pkScript, or else verification will fail since the new sighash
/// digest algorithm defined in BIP0143 includes the input value in the sighash.
void _spendNestedWitnessPubKeyHash(
    TxIn txIn,
    Uint8List pkScript,
    utils.Amount inputValue,
    chaincfg.Params net,
    txscript.KeyClosure kdb,
    txscript.ScriptClosure sdb,
    MsgTx tx,
    txscript.TxSigHashes hashCache,
    int idx) {
  var data = txscript.extractPkScriptAddrs(pkScript, net);
  List<utils.Address> addrs = data[1];

  var resp = kdb.getKey(addrs[0]);
  var pubKeyHash = sdb.getScript(addrs[0]);

  var p2wkhAddr = utils.AddressWitnessPubKeyHash(hash: pubKeyHash, net: net);

  var witnessProgram = txscript.payToAddrScript(p2wkhAddr);

  var sigScript = txscript.ScriptBuilder().addData(witnessProgram).script();

  txIn.signatureScript = sigScript;

  var witnessScript = txscript.witnessSignature(tx, hashCache, idx, inputValue,
      witnessProgram, txscript.SIG_HASH_ALL, resp.key, resp.compressed);
  txIn.witness = witnessScript;
}

/// AddAllInputScripts modifies transaction a transaction by adding inputs
/// scripts for each input.  Previous output scripts being redeemed by each input
/// are passed in prevPkScripts and the slice length must match the number of
/// inputs.  Private keys and redeem scripts are looked up using a SecretsSource
/// based on the previous output script.
void addAllInputScripts(
    MsgTx tx,
    List<Uint8List> prevPkScripts,
    List<utils.Amount> inputValues,
    chaincfg.Params net,
    txscript.KeyClosure kdb,
    txscript.ScriptClosure sdb) {
  var inputs = tx.txIn;
  var hashCache = txscript.TxSigHashes(tx);

  if (inputs.length != prevPkScripts.length) {
    throw FormatException('tx.TxIn and prevPkScripts slices must '
        'have equal length');
  }
  for (var i = 0; i < inputs.length; i++) {
    var pkScript = prevPkScripts[i];
    if (txscript.isPayToScriptHash(pkScript)) {
      _spendNestedWitnessPubKeyHash(
          inputs[i], pkScript, inputValues[i], net, kdb, sdb, tx, hashCache, i);
    } else if (txscript.isPayToWitnessPubKeyHash(pkScript)) {
      _spendWitnessKeyHash(
          inputs[i], pkScript, inputValues[i], net, kdb, sdb, tx, hashCache, i);
    } else {
      var sigScript = inputs[i].signatureScript;
      var script = txscript.signTxOutput(
          net, tx, i, pkScript, txscript.SIG_HASH_ALL, kdb, sdb, sigScript);

      inputs[i].signatureScript = script;
    }
  }
}
