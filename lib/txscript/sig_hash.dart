part of bitcoin.txscript;

const SIG_HASH_ALL = 0x1;
const SIG_HASH_NONE = 0x2;
const SIG_HASH_SINGLE = 0x3;
const SIG_HASH_ANY_ONE_CAN_PAY = 0x80;
const SIG_HASH_MASK = 0x1f;
const SIG_HASH_SERIALIZE_PREFIX = 1;
const SIG_HASH_SERIALIZE_WITNESS = 3;

int sigHashPrefixSerializeSize(int hashType, List<transaction.TxIn> txIns,
    List<transaction.TxOut> txOuts, int signIdx) {
  var numTxIns = txIns.length;
  var numTxOuts = txOuts.length;

  var size = 4 +
      transaction.varIntSerializeSize(numTxIns) +
      numTxIns * (chainhash.HASH_SIZE + 4 + 1 + 4) +
      transaction.varIntSerializeSize(numTxOuts) +
      numTxOuts * (8 + 2) +
      4 +
      4;
  for (var i = 0; i < txOuts.length; i++) {
    var txOut = txOuts[i];
    var pkScript = txOut.pkScript;
    if (hashType & SIG_HASH_MASK == SIG_HASH_SINGLE && i != signIdx) {
      pkScript = Uint8List(0);
    }
    size += transaction.varIntSerializeSize(pkScript.length);
    size += pkScript.length;
  }

  return size;
}

int sigHashWitnessSerializeSize(
    int hashType, List<transaction.TxIn> txIns, Uint8List signScript) {
  var numTxIns = txIns.length;
  return 4 +
      transaction.varIntSerializeSize(numTxIns) +
      (numTxIns - 1) +
      transaction.varIntSerializeSize(signScript.length) +
      signScript.length;
}

Uint8List calcSignatureHash(List<ParsedOpcode> prevOutScript, int hashType,
    transaction.MsgTx tx, int idx) {
  if ((hashType & SIG_HASH_MASK == SIG_HASH_SINGLE) &&
      (idx >= tx.txOut.length)) {
    throw FormatException(
        'attempt to sign single input at index ${idx} >= ${tx.txOut.length} outputs');
  }

  removeOpcode(prevOutScript, OP_CODESEPARATOR);
  Uint8List signScript;
  try {
    signScript = unparseScript(prevOutScript);
  } catch (_) {
    print(_);
  }
  var txBuf = ByteData(tx.serializeSize());
  tx.serialize(txBuf);

  var txCopy = transaction.MsgTx.fromBytes(txBuf);
  txCopy.txIn[idx].signatureScript = signScript;
  for(var i = 0; i < txCopy.txIn.length; i++){
    if (i != idx) {
      txCopy.txIn[i].signatureScript = null;
    }
  }

  switch (hashType & SIG_HASH_MASK) {
    case SIG_HASH_NONE:
      txCopy.txOut.clear();
      for(var i = 0; i < txCopy.txIn.length; i++){
        if (i != idx) {
          txCopy.txIn[i].sequence = 0;
        }
      }
      break;
    case SIG_HASH_SINGLE:
      txCopy.txOut = txCopy.txOut.sublist(0, idx+1);

      for (var i = 0; i < idx; i++) {
        txCopy.txOut[i].value = utils.Amount(-1);
        txCopy.txOut[i].pkScript = null;
      }

      for(var i = 0; i < txCopy.txIn.length; i++){
        if (i != idx) {
          txCopy.txIn[i].sequence = 0;
        }
      }
      break;
  }

  ByteData wbuf = ByteData(txCopy.serializeSizeStripped() + 4);
  txCopy.serializeNoWitness(wbuf);
  wbuf.setUint32(wbuf.lengthInBytes - 4, hashType, Endian.little);
  return chainhash.hashB(chainhash.hashB(wbuf.buffer.asUint8List()));
}
