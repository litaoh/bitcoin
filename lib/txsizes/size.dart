part of bitcoins.txsizes;

const int WITNESS_SCALE_FACTOR = 4;

/// P2PKHPkScriptSize is the size of a transaction output script that
/// pays to a compressed pubkey hash.  It is calculated as:
///
///   - OP_DUP
///   - OP_HASH160
///   - OP_DATA_20
///   - 20 bytes pubkey hash
///   - OP_EQUALVERIFY
///   - OP_CHECKSIG
const int P2PKH_PK_SCRIPT_SIZE = 1 + 1 + 1 + 20 + 1 + 1;

/// P2PKHOutputSize is the serialize size of a transaction output with a
/// P2PKH output script.  It is calculated as:
///
///   - 8 bytes output value
///   - 1 byte compact int encoding value 25
///   - 25 bytes P2PKH output script
const int P2PKH_OUTPUT_SIZE = 8 + 1 + P2PKH_PK_SCRIPT_SIZE;

/// RedeemP2PKHSigScriptSize is the worst case (largest) serialize size
/// of a transaction input script that redeems a compressed P2PKH output.
/// It is calculated as:
///
///   - OP_DATA_73
///   - 72 bytes DER signature + 1 byte sighash
///   - OP_DATA_33
///   - 33 bytes serialized compressed pubkey
const int REDEEM_P2PKH_SIG_SCRIPT_SIZE = 1 + 73 + 1 + 33;

/// RedeemP2PKHInputSize is the worst case (largest) serialize size of a
/// transaction input redeeming a compressed P2PKH output.  It is
/// calculated as:
///
///   - 32 bytes previous tx
///   - 4 bytes output index
///   - 1 byte compact int encoding value 107
///   - 107 bytes signature script
///   - 4 bytes sequence
const int REDEEM_P2PKH_INPUT_SIZE =
    32 + 4 + 1 + REDEEM_P2PKH_SIG_SCRIPT_SIZE + 4;

/// RedeemP2WPKHScriptSize is the size of a transaction input script
/// that spends a pay-to-witness-public-key hash (P2WPKH). The redeem
/// script for P2WPKH spends MUST be empty.
const int REDEEM_P2WPKH_SCRIPT_SIZE = 0;

/// RedeemP2WPKHInputSize is the worst case size of a transaction
/// input redeeming a P2WPKH output. It is calculated as:
///
///   - 32 bytes previous tx
///   - 4 bytes output index
///   - 1 byte encoding empty redeem script
///   - 0 bytes redeem script
///   - 4 bytes sequence
const int REDEEM_P2WPKH_INPUT_SIZE = 32 + 4 + 1 + REDEEM_P2WPKH_SCRIPT_SIZE + 4;

/// P2WPKHPkScriptSize is the size of a transaction output script that
/// pays to a witness pubkey hash. It is calculated as:
///
///   - OP_0
///   - OP_DATA_20
///   - 20 bytes pubkey hash
const int P2WPKH_PK_SCRIPT_SIZE = 1 + 1 + 20;

/// P2WPKHOutputSize is the serialize size of a transaction output with a
/// P2WPKH output script. It is calculated as:
///
///   - 8 bytes output value
///   - 1 byte compact int encoding value 22
///   - 22 bytes P2PKH output script
const int P2WPKH_OUTPUT_SIZE = 8 + 1 + P2WPKH_PK_SCRIPT_SIZE;

/// RedeemNestedP2WPKHScriptSize is the worst case size of a transaction
/// input script that redeems a pay-to-witness-key hash nested in P2SH
/// (P2SH-P2WPKH). It is calculated as:
///
///   - 1 byte compact int encoding value 22
///   - OP_0
///   - 1 byte compact int encoding value 20
///   - 20 byte key hash
const int REDEEM_NESTED_P2WPKH_SCRIPT_SIZE = 1 + 1 + 1 + 20;

/// RedeemNestedP2WPKHInputSize is the worst case size of a
/// transaction input redeeming a P2SH-P2WPKH output. It is
/// calculated as:
///
///   - 32 bytes previous tx
///   - 4 bytes output index
///   - 1 byte compact int encoding value 23
///   - 23 bytes redeem script (scriptSig)
///   - 4 bytes sequence
const int REDEEM_NESTED_P2WPKH_INPUT_SIZE =
    32 + 4 + 1 + REDEEM_NESTED_P2WPKH_SCRIPT_SIZE + 4;

/// RedeemP2WPKHInputWitnessWeight is the worst case weight of
/// a witness for spending P2WPKH and nested P2WPKH outputs. It
/// is calculated as:
///
///   - 1 wu compact int encoding value 2 (number of items)
///   - 1 wu compact int encoding value 73
///   - 72 wu DER signature + 1 wu sighash
///   - 1 wu compact int encoding value 33
///   - 33 wu serialized compressed pubkey
const int REDEEM_P2WPKH_INPUT_WITNESS_WEIGHT = 1 + 1 + 73 + 1 + 33;

/// sumOutputSerializeSizes sums up the serialized size of the supplied outputs.
int sumOutputSerializeSizes(List<transaction.TxOut> outputs) {
  var serializeSize = 0;
  for (var i = 0; i < outputs.length; i++) {
    serializeSize += outputs[i].serializeSize();
  }
  return serializeSize;
}

/// EstimateSerializeSize returns a worst case serialize size estimate for a
/// signed transaction that spends inputCount number of compressed P2PKH outputs
/// and contains each transaction output from txOuts.  The estimated size is
/// incremented for an additional P2PKH change output if addChangeOutput is true.
int estimateSerializeSize(
    int inputCount, List<transaction.TxOut> txOuts, bool addChangeOutput) {
  var changeSize = 0;
  var outputCount = txOuts.length;
  if (addChangeOutput) {
    changeSize = P2PKH_OUTPUT_SIZE;
    outputCount++;
  }

  return 8 +
      transaction.varIntSerializeSize(inputCount) +
      transaction.varIntSerializeSize(outputCount) +
      inputCount * REDEEM_P2PKH_INPUT_SIZE +
      sumOutputSerializeSizes(txOuts) +
      changeSize;
}

/// EstimateVirtualSize returns a worst case virtual size estimate for a
/// signed transaction that spends the given number of P2PKH, P2WPKH and
/// (nested) P2SH-P2WPKH outputs, and contains each transaction output
/// from txOuts. The estimate is incremented for an additional P2PKH
/// change output if addChangeOutput is true.
int estimateVirtualSize(
    int numP2PKHIns,
    int numP2WPKHIns,
    int numNestedP2WPKHIns,
    List<transaction.TxOut> txOuts,
    bool addChangeOutput) {
  var changeSize = 0;
  if (addChangeOutput) {
    // We are always using P2WPKH as change output.
    changeSize = P2WPKH_OUTPUT_SIZE;
  }

  /// Version 4 bytes + LockTime 4 bytes + Serialized var int size for the
  /// number of transaction inputs and outputs + size of redeem scripts +
  /// the size out the serialized outputs and change.
  var baseSize = 8 +
      transaction.varIntSerializeSize(
          numP2PKHIns + numP2WPKHIns + numNestedP2WPKHIns) +
      transaction.varIntSerializeSize(txOuts.length) +
      numP2PKHIns * REDEEM_P2PKH_INPUT_SIZE +
      numP2WPKHIns * REDEEM_P2WPKH_INPUT_SIZE +
      numNestedP2WPKHIns * REDEEM_NESTED_P2WPKH_INPUT_SIZE +
      sumOutputSerializeSizes(txOuts) +
      changeSize;

  /// If this transaction has any witness inputs, we must count the
  /// witness data.
  var witnessWeight = 0;
  if (numP2WPKHIns + numNestedP2WPKHIns > 0) {
    /// Additional 2 weight units for segwit marker + flag.
    witnessWeight = 2 +
        transaction.varIntSerializeSize(numP2WPKHIns + numNestedP2WPKHIns) +
        numP2WPKHIns * REDEEM_P2WPKH_INPUT_WITNESS_WEIGHT +
        numNestedP2WPKHIns * REDEEM_P2WPKH_INPUT_WITNESS_WEIGHT;
  }

  /// We add 3 to the witness weight to make sure the result is
  /// always rounded up.
  return baseSize + (witnessWeight + 3) ~/ WITNESS_SCALE_FACTOR;
}
