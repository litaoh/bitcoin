part of bitcoins.txscript;

class TxSigHashes {
  chainhash.Hash hashPrevOuts;
  chainhash.Hash hashSequence;
  chainhash.Hash hashOutputs;
  TxSigHashes(transaction.MsgTx tx) {
    hashPrevOuts = _calcHashPrevOuts(tx);
    hashSequence = _calcHashSequence(tx);
    hashOutputs = _calcHashOutputs(tx);
  }

  int get length {
    return hashPrevOuts.length + hashSequence.length + hashOutputs.length;
  }
}

/// _calcHashPrevOuts calculates a single hash of all the previous outputs
/// (txid:index) referenced within the passed transaction. This calculated hash
/// can be re-used when validating all inputs spending segwit outputs, with a
/// signature hash type of SigHashAll. This allows validation to re-use previous
/// hashing computation, reducing the complexity of validating SigHashAll inputs
/// from  O(N^2) to O(N).
chainhash.Hash _calcHashPrevOuts(transaction.MsgTx tx) {
  int size = 0;
  for (int i = 0; i < tx.txIn.length; i++) {
    size += tx.txIn[i].previousOutPoint.length;
  }
  ByteData b = ByteData(size);
  int offset = 0;

  for (int i = 0; i < tx.txIn.length; i++) {
    offset = transaction.copyBytes(
        b, tx.txIn[i].previousOutPoint.hash.cloneBytes(), offset);
    b.setUint32(offset, tx.txIn[i].previousOutPoint.index, Endian.little);
    offset += 4;
  }

  return chainhash.hashH(chainhash.hashB(b.buffer.asUint8List()));
}

/// _calcHashSequence computes an aggregated hash of each of the sequence numbers
/// within the inputs of the passed transaction. This single hash can be re-used
/// when validating all inputs spending segwit outputs, which include signatures
/// using the SigHashAll sighash type. This allows validation to re-use previous
/// hashing computation, reducing the complexity of validating SigHashAll inputs
/// from O(N^2) to O(N).
chainhash.Hash _calcHashSequence(transaction.MsgTx tx) {
  ByteData b = ByteData(4 * tx.txIn.length);
  int offset = 0;
  for (int i = 0; i < tx.txIn.length; i++) {
    b.setUint32(offset, tx.txIn[i].sequence, Endian.little);
    offset += 4;
  }

  return chainhash.hashH(chainhash.hashB(b.buffer.asUint8List()));
}

/// _calcHashOutputs computes a hash digest of all outputs created by the
/// transaction encoded using the wire format. This single hash can be re-used
/// when validating all inputs spending witness programs, which include
/// signatures using the SigHashAll sighash type. This allows computation to be
/// cached, reducing the total hashing complexity from O(N^2) to O(N).
chainhash.Hash _calcHashOutputs(transaction.MsgTx tx) {
  int size = 0;
  for (int i = 0; i < tx.txOut.length; i++) {
    size += tx.txOut[i].serializeSize();
  }
  ByteData b = ByteData(size);
  int offset = 0;
  for (int i = 0; i < tx.txOut.length; i++) {
    offset = transaction.writeTxOut(b, tx.txOut[i], offset);
  }

  return chainhash.hashH(chainhash.hashB(b.buffer.asUint8List()));
}
