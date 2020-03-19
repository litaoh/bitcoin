part of bitcoin.transaction;

/// GENERATED_TX_VERSION is the version of the transaction being generated.
/// It is defined as a constant here rather than using the wire.TxVersion
/// constant since a change in the transaction version will potentially
/// require changes to the generated transaction.  Thus, using the wire
/// constant for the generated transaction version could allow creation
/// of invalid transactions for the updated version.
const int GENERATED_TX_VERSION = 1;

class AuthoredTx {
  MsgTx tx;
  List<Uint8List> prevScripts;
  utils.Amount totalInput;
  int changeIndex;
  int estimatedSignedSerializeSize;
  AuthoredTx(
      {this.tx,
      this.prevScripts,
      this.totalInput,
      this.changeIndex,
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

    int nested = 0, p2wpkh = 0, p2pkh = 0;
    for (int i = 0; i < inputDetail.scripts.length; i++) {
      Uint8List pkScript = inputDetail.scripts[i];
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
      serType: TX_SERIALIZE_FULL,
      version: GENERATED_TX_VERSION,
      txIn: inputDetail.inputs,
      txOut: outputs,
      lockTime: 0,
    );
    var changeAmount = inputDetail.amount.toCoin() -
        targetAmount.toCoin() -
        maxRequiredFee.toCoin();
    if (changeAmount != BigInt.zero &&
        !txrules.isDustAmount(utils.Amount.fromUnit(changeAmount),
            txsizes.P2WPKH_PK_SCRIPT_SIZE, relayFeePerKb)) {
      fetchChange.script();
      var changeScript = fetchChange.hash;

//      if (changeScript.length > txsizes.P2WPKH_PK_SCRIPT_SIZE) {
//        throw FormatException(
//            'fee estimation requires change scripts no larger than P2WPKH output scripts');
//      }
      var change = TxOut(
        value: utils.Amount.fromUnit(changeAmount),
        pkScript: changeScript,
      );
      outputs.add(change);
    }

    return AuthoredTx(
        tx: unsignedTransaction,
        prevScripts: inputDetail.scripts,
        totalInput: inputDetail.amount);
  }
}
