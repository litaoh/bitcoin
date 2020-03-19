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
    transaction.MsgTx tx, int idx, chainhash.Hash cachedPrefix) {
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

  var txIns = tx.txIn;

  var signTxInIdx = idx;
  if ((hashType & SIG_HASH_ANY_ONE_CAN_PAY) != 0) {
    txIns = tx.txIn.sublist(idx, idx + 1);
    signTxInIdx = 0;
  }

  chainhash.Hash prefixHash;
  if (chaincfg.SIG_HASH_OPTIMIZATION &&
      (cachedPrefix != null) &&
      hashType & SIG_HASH_MASK == SIG_HASH_ALL &&
      hashType & SIG_HASH_ANY_ONE_CAN_PAY == 0) {
    prefixHash = cachedPrefix;
  } else {
    var txOuts = tx.txOut;
    var sig = hashType & SIG_HASH_MASK;

    if (sig == SIG_HASH_NONE) {
      txOuts = null;
    } else if (sig == SIG_HASH_SINGLE) {
      txOuts = tx.txOut.sublist(0, idx + 1);
    }

    var size = sigHashPrefixSerializeSize(hashType, txIns, txOuts, idx);

    var prefixBuf = ByteData(size);
    var version = tx.version | SIG_HASH_SERIALIZE_PREFIX << 16;

    var offset = 0;
    prefixBuf.setUint32(offset, version, Endian.little);
    offset += 4;

    offset = transaction.writeVarInt(prefixBuf, txIns.length, offset);

    for (var i = 0; i < txIns.length; i++) {
      var txIn = txIns[i];
      var prevOut = txIn.previousOutPoint;
      var hash = prevOut.hash.cloneBytes();

      offset = transaction.copyBytes(prefixBuf, hash, offset);

      prefixBuf.setUint32(offset, prevOut.index, Endian.little);
      offset += 4;
      prefixBuf.setUint8(offset, prevOut.tree);
      offset += 1;

      var sequence = txIn.sequence;

      if (((hashType & SIG_HASH_MASK) == SIG_HASH_NONE ||
              (hashType & SIG_HASH_MASK) == SIG_HASH_SINGLE) &&
          (i != signTxInIdx)) {
        sequence = 0;
      }
      prefixBuf.setUint32(offset, sequence, Endian.little);
      offset += 4;
    }

    offset = transaction.writeVarInt(prefixBuf, txOuts.length, offset);

    for (var i = 0; i < txOuts.length; i++) {
      var txOut = txOuts[i];

      var value = txOut.value.toCoin();
      var pkScript = txOut.pkScript;
      if (((hashType & SIG_HASH_MASK) == SIG_HASH_SINGLE) && (i != idx)) {
        value = BigInt.from(-1);
        pkScript = Uint8List(0);
      }

      offset = transaction.writeUInt64LE(prefixBuf, value.toInt(), offset);

      prefixBuf.setUint16(offset, txOut.version, Endian.little);
      offset += 2;

      offset = transaction.writeVarInt(prefixBuf, pkScript.length, offset);

      offset = transaction.copyBytes(prefixBuf, pkScript, offset);
    }

    prefixBuf.setUint32(offset, tx.lockTime, Endian.little);
    offset += 4;
    prefixBuf.setUint32(offset, tx.expiry, Endian.little);
    offset += 4;

    prefixHash = chainhash.hashH(prefixBuf.buffer.asUint8List());
  }

  var size = sigHashWitnessSerializeSize(hashType, txIns, signScript);

  var witnessBuf = ByteData(size);

  var version = tx.version | SIG_HASH_SERIALIZE_WITNESS << 16;

  var offset = 0;
  witnessBuf.setUint32(offset, version, Endian.little);
  offset += 4;
  offset = transaction.writeVarInt(witnessBuf, txIns.length, offset);

  for (var i = 0; i < txIns.length; i++) {
    var commitScript = signScript;
    if (i != signTxInIdx) {
      commitScript = Uint8List(0);
    }

    offset = transaction.writeVarInt(witnessBuf, commitScript.length, offset);
    offset = transaction.copyBytes(witnessBuf, commitScript, offset);
  }
  var witnessHash = chainhash.hashH(witnessBuf.buffer.asUint8List());

  var sigHashBuf = ByteData(chainhash.HASH_SIZE * 2 + 4);
  offset = 0;
  sigHashBuf.setUint32(offset, hashType, Endian.little);
  offset += 4;

  var hash = prefixHash.cloneBytes();
  offset = transaction.copyBytes(sigHashBuf, hash, offset);

  hash = witnessHash.cloneBytes();
  offset = transaction.copyBytes(sigHashBuf, hash, offset);
  offset += hash.length;
  return chainhash.hashB(sigHashBuf.buffer.asUint8List());
}
