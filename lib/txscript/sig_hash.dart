part of bitcoins.txscript;

const SIG_HASH_ALL = 0x1;
const SIG_HASH_NONE = 0x2;
const SIG_HASH_SINGLE = 0x3;
const SIG_HASH_ANY_ONE_CAN_PAY = 0x80;
const SIG_HASH_MASK = 0x1f;

/// version + OutPoint.index + sequence + lockTime + hashType
/// + sigHashes + amount
int _sigHashWitnessSerializeSize(
    List<ParsedOpcode> subScript, TxSigHashes sigHashes) {
  var size = 4 * 5 + sigHashes.length + chainhash.HASH_SIZE + 8;
  if (isWitnessPubKeyHash(subScript)) {
    size += 6 + subScript[1].data.length;
  } else {
    size += unparseScript(subScript).length;
  }
  return size;
}

/// calcSignatureHash will, given a script and hash type for the current script
/// engine instance, calculate the signature hash to be used for signing and
/// verification.
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
  for (var i = 0; i < txCopy.txIn.length; i++) {
    if (i != idx) {
      txCopy.txIn[i].signatureScript = null;
    }
  }

  switch (hashType & SIG_HASH_MASK) {
    case SIG_HASH_NONE:
      txCopy.txOut.clear();
      for (var i = 0; i < txCopy.txIn.length; i++) {
        if (i != idx) {
          txCopy.txIn[i].sequence = 0;
        }
      }
      break;
    case SIG_HASH_SINGLE:
      txCopy.txOut = txCopy.txOut.sublist(0, idx + 1);

      for (var i = 0; i < idx; i++) {
        txCopy.txOut[i].value = utils.Amount(BigInt.from(-1));
        txCopy.txOut[i].pkScript = null;
      }

      for (var i = 0; i < txCopy.txIn.length; i++) {
        if (i != idx) {
          txCopy.txIn[i].sequence = 0;
        }
      }
      break;
  }

  var wbuf = ByteData(txCopy.serializeSizeStripped() + 4);
  txCopy.serializeNoWitness(wbuf);
  wbuf.setUint32(wbuf.lengthInBytes - 4, hashType, Endian.little);
  return chainhash.hashB(chainhash.hashB(wbuf.buffer.asUint8List()));
}

///calc Witness Signature Hash
Uint8List calcWitnessSignatureHash(
    List<ParsedOpcode> subScript,
    TxSigHashes sigHashes,
    int hashType,
    transaction.MsgTx tx,
    int idx,
    utils.Amount amt) {
  if (idx > tx.txIn.length - 1) {
    throw FormatException('idx ${idx} but ${tx.txIn.length} txins');
  }

  var offset = 0;
  var sigHash = ByteData(_sigHashWitnessSerializeSize(subScript, sigHashes));

  sigHash.setUint32(offset, tx.version, Endian.little);
  offset += 4;

  var zeroHash = chainhash.Hash(Uint8List(chainhash.HASH_SIZE));

  if (hashType & SIG_HASH_ANY_ONE_CAN_PAY == 0) {
    offset = transaction.copyBytes(
        sigHash, sigHashes.hashPrevOuts.cloneBytes(), offset);
  } else {
    offset = transaction.copyBytes(sigHash, zeroHash.cloneBytes(), offset);
  }

  if (hashType & SIG_HASH_ANY_ONE_CAN_PAY == 0 &&
      hashType & SIG_HASH_MASK != SIG_HASH_SINGLE &&
      hashType & SIG_HASH_MASK != SIG_HASH_NONE) {
    offset = transaction.copyBytes(
        sigHash, sigHashes.hashSequence.cloneBytes(), offset);
  } else {
    offset = transaction.copyBytes(sigHash, zeroHash.cloneBytes(), offset);
  }

  var txIn = tx.txIn[idx];
  offset = transaction.copyBytes(
      sigHash, txIn.previousOutPoint.hash.cloneBytes(), offset);
  sigHash.setUint32(offset, txIn.previousOutPoint.index, Endian.little);

  offset += 4;
  if (isWitnessPubKeyHash(subScript)) {
    sigHash.setUint8(offset++, 0x19);
    sigHash.setUint8(offset++, OP_DUP);
    sigHash.setUint8(offset++, OP_HASH160);
    sigHash.setUint8(offset++, OP_DATA_20);
    offset = transaction.copyBytes(sigHash, subScript[1].data, offset);
    sigHash.setUint8(offset++, OP_EQUALVERIFY);
    sigHash.setUint8(offset++, OP_CHECKSIG);
  } else {
    var rawScript = unparseScript(subScript);

    offset = transaction.writeVarBytes(sigHash, rawScript, offset);
  }

  offset = transaction.copyBytes(sigHash, amt.bytes(), offset);
  sigHash.setUint32(offset, txIn.sequence, Endian.little);

  offset += 4;

  if (hashType & SIG_HASH_SINGLE != SIG_HASH_SINGLE &&
      hashType & SIG_HASH_NONE != SIG_HASH_NONE) {
    offset = transaction.copyBytes(
        sigHash, sigHashes.hashOutputs.cloneBytes(), offset);
  } else if (hashType & SIG_HASH_MASK == SIG_HASH_SINGLE &&
      idx < tx.txOut.length) {
    var b = ByteData(tx.txOut[idx].serializeSize());
    transaction.writeTxOut(b, tx.txOut[idx], 0);
    offset = transaction.copyBytes(sigHash,
        chainhash.hashB(chainhash.hashB(b.buffer.asUint8List())), offset);
  } else {
    offset = transaction.copyBytes(sigHash, zeroHash.cloneBytes(), offset);
  }
  sigHash.setUint32(offset, tx.lockTime, Endian.little);
  offset += 4;

  sigHash.setUint32(offset, hashType, Endian.little);
  offset += 4;

  return chainhash.hashB(chainhash.hashB(sigHash.buffer.asUint8List()));
}
