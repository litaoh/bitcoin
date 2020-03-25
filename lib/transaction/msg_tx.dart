part of bitcoins.transaction;

/// MAX_MESSAGE_PAYLOAD is the maximum bytes a message can be regardless of other
/// individual limits imposed by messages themselves.
const int MAX_MESSAGE_PAYLOAD = (1024 * 1024 * 32);

/// MAX_TX_IN_SEQUENCE_NUM is the maximum sequence number the sequence field
/// of a transaction input can be.
const int MAX_TX_IN_SEQUENCE_NUM = 0xffffffff;

/// MIN_TX_IN_PAYLOAD is the minimum payload size for a transaction input.
/// PreviousOutPoint.Hash + PreviousOutPoint.Index 4 bytes +
/// PreviousOutPoint.Tree 1 byte + Varint for SignatureScript length 1
/// byte + Sequence 4 bytes.
const int MIN_TX_IN_PAYLOAD = 11 + chainhash.HASH_SIZE;

/// MAX_TX_IN_PER_MESSAGE is the maximum number of transactions inputs that
/// a transaction which fits into a message could possibly have.
const int MAX_TX_IN_PER_MESSAGE =
    (MAX_MESSAGE_PAYLOAD ~/ MIN_TX_IN_PAYLOAD) + 1;

/// MIN_TX_OUT_PAYLOAD is the minimum payload size for a transaction output.
/// Value 8 bytes + Varint for PkScript length 1 byte.
const int MIN_TX_OUT_PAYLOAD = 9;

/// MAX_TX_OUT_PER_MESSAGE is the maximum number of transactions outputs that
/// a transaction which fits into a message could possibly have.
const int MAX_TX_OUT_PER_MESSAGE =
    (MAX_MESSAGE_PAYLOAD ~/ MIN_TX_OUT_PAYLOAD) + 1;

const int MAX_WITNESS_ITEM_SIZE = 11000;
const int BASE_ENCODING = 1;

/// WITNESS_ENCODING encodes all messages other than transaction messages
/// using the default bitcoins wire protocol specification. For transaction
/// messages, the new encoding format detailed in BIP0144 will be used.
const int WITNESS_ENCODING = 2;

class MsgTx {
  int version;
  List<TxIn> txIn;
  List<TxOut> txOut;
  int lockTime;
  MsgTx({
    this.version,
    this.txIn,
    this.txOut,
    this.lockTime,
  });

  void addTxIn(TxIn ti) {
    txIn.add(ti);
  }

  void addTxOut(TxOut to) {
    txOut.add(to);
  }

  int serializeSizeStripped() {
    return _baseSize();
  }

  /// baseSize returns the serialized size of the transaction without accounting
  /// for any witness data.
  int _baseSize() {
    /// Version 4 bytes + LockTime 4 bytes + Serialized varint size for the
    /// number of transaction inputs and outputs.
    var n = 8 +
        varIntSerializeSize(txIn.length) +
        varIntSerializeSize(txOut.length);
    for (var i = 0; i < txIn.length; i++) {
      n += txIn[i].serializeSize();
    }

    for (var i = 0; i < txOut.length; i++) {
      n += txOut[i].serializeSize();
    }

    return n;
  }

  bool hasWitness() {
    for (var i = 0; i < txIn.length; i++) {
      if (txIn[i].witness?.isNotEmpty ?? false) {
        return true;
      }
    }

    return false;
  }

  int serializeSize() {
    var n = _baseSize();

    if (hasWitness()) {
      /// The marker, and flag fields take up two additional bytes.
      n += 2;

      /// Additionally, factor in the serialized size of each of the
      /// witnesses for each txin.
      for (var i = 0; i < txIn.length; i++) {
        n += txIn[i].serializeSizeWitness();
      }
    }
    return n;
  }

  void decode(ByteData buf, [int offset = 0, int enc = WITNESS_ENCODING]) {
    version = buf.getUint32(offset, Endian.little);
    offset += 4;
    var data = readVarInt(buf, offset);
    var count = data[0];
    offset = data[1];
    var flag = 0;
    if (count == 0) {
      flag = buf.getUint8(offset);
      offset++;
      if (flag != 0x01) {
        throw FormatException(
            'MsgTx.BtcDecode: witness tx but flag byte is ${flag}');
      }
      data = readVarInt(buf, offset);
      count = data[0];
      offset = data[1];
    }
    if (count > MAX_TX_IN_PER_MESSAGE) {
      throw FormatException('MsgTx.BtcDecode: '
          'too many input transactions to fit into '
          'max message size [count ${count}, max ${MAX_TX_IN_PER_MESSAGE}]');
    }

    /// Deserialize the inputs.
    txIn = <TxIn>[];
    for (var i = 0; i < count; i++) {
      txIn.add(TxIn());
      offset = _readTxIn(buf, txIn[i], offset);
    }

    data = readVarInt(buf, offset);
    count = data[0];
    offset = data[1];

    if (count > MAX_TX_OUT_PER_MESSAGE) {
      throw FormatException('MsgTx.BtcDecode:'
          'too many output transactions to fit into '
          'max message size [count ${count}, max ${MAX_TX_OUT_PER_MESSAGE}]');
    }

    txOut = <TxOut>[];
    for (var i = 0; i < count; i++) {
      txOut.add(TxOut());
      offset = _readTxOut(buf, txOut[i], offset);
    }

    if (flag != 0 && enc == WITNESS_ENCODING) {
      for (var i = 0; i < txIn.length; i++) {
        data = readVarInt(buf, offset);
        var witCount = data[0];
        offset = data[1];
        txIn[i].witness = <Uint8List>[];
        for (var j = 0; j < witCount; j++) {
          var d = _readScript(
              buf, MAX_WITNESS_ITEM_SIZE, offset, 'script witness item');
          txIn[i].witness.add(d[0]);
          offset = d[1];
        }
      }
    }

    lockTime = buf.getUint32(offset, Endian.little);
    offset += 4;
  }

  void encode(ByteData buf, [int offset = 0, int enc = WITNESS_ENCODING]) {
    buf.setUint32(offset, version, Endian.little);
    offset += 4;

    var doWitness = enc == WITNESS_ENCODING && hasWitness();
    if (doWitness) {
      buf.setUint16(offset, 1);
      offset += 2;
    }

    var count = txIn.length;

    offset = writeVarInt(buf, count, offset);
    for (var i = 0; i < txIn.length; i++) {
      offset = _writeTxIn(buf, txIn[i], offset);
    }

    count = txOut.length;
    offset = writeVarInt(buf, count, offset);
    for (var i = 0; i < txOut.length; i++) {
      offset = writeTxOut(buf, txOut[i], offset);
    }

    if (doWitness) {
      for (var i = 0; i < txIn.length; i++) {
        offset = _writeTxWitness(buf, version, txIn[i].witness, offset);
      }
    }

    buf.setUint32(offset, lockTime ?? 0, Endian.little);
  }

  void serializeNoWitness(ByteData buf) {
    encode(buf, 0, BASE_ENCODING);
  }

  void serialize(ByteData buf) {
    encode(buf, 0, WITNESS_ENCODING);
  }

  static MsgTx fromBytes(ByteData buf) {
    var msgTx = MsgTx();
    msgTx.decode(buf);
    return msgTx;
  }
}

List<dynamic> _readScript(
    ByteData buf, int maxAllowed, int offset, String fieldName) {
  var data = readVarInt(buf, offset);
  var count = data[0];
  offset = data[1];

  if (count > maxAllowed) {
    throw FormatException(
        '${fieldName} is larger than the max allowed size [count ${count}, max ${maxAllowed}]');
  }

  return [
    buf.buffer.asUint8List().sublist(offset, offset + count),
    offset + count
  ];
}

/// readOutPoint reads the next sequence of bytes from r as an OutPoint.
int _readOutPoint(ByteData buf, TxIn ti, int offset) {
  var hash =
      buf.buffer.asUint8List().sublist(offset, offset + chainhash.HASH_SIZE);
  offset += chainhash.HASH_SIZE;
  var index = buf.getUint32(offset, Endian.little);
  offset += 4;

  ti.previousOutPoint = OutPoint(
    hash: chainhash.Hash(hash),
    index: index,
  );

  return offset;
}

int _writeOutPoint(ByteData buf, OutPoint op, int offset) {
  var hash = op.hash.cloneBytes();
  offset = copyBytes(buf, hash, offset);
  buf.setUint32(offset, op.index, Endian.little);
  offset += 4;
  return offset;
}

/// _readTxIn reads the next sequence of bytes from r as a transaction input
/// (TxIn).
int _readTxIn(ByteData buf, TxIn ti, int offset) {
  offset = _readOutPoint(buf, ti, offset);
  var data = _readScript(
      buf, MAX_MESSAGE_PAYLOAD, offset, 'transaction input signature script');
  ti.signatureScript = data[0];
  offset = data[1];
  ti.sequence = buf.getUint32(offset, Endian.little);
  offset += 4;
  return offset;
}

int _writeTxIn(ByteData buf, TxIn ti, int offset) {
  offset = _writeOutPoint(buf, ti.previousOutPoint, offset);

  offset = writeVarBytes(buf, ti.signatureScript, offset);
  buf.setUint32(offset, ti.sequence, Endian.little);
  offset += 4;
  return offset;
}

/// readTxOut reads the next sequence of bytes from r as a transaction output
/// (TxOut).
int _readTxOut(ByteData buf, TxOut to, int offset) {
  to.value =
      utils.Amount.fromUnit(BigInt.from(buf.getUint32(offset, Endian.little)));
  offset += 8;

  var data = _readScript(
      buf, MAX_MESSAGE_PAYLOAD, offset, 'transaction input signature script');
  to.pkScript = data[0];
  offset = data[1];
  return offset;
}

/// write TxOut
int writeTxOut(ByteData buf, TxOut to, int offset) {
  buf.setUint64(offset, to.value.toCoin().toInt(), Endian.little);
  offset += 8;
  return writeVarBytes(buf, to.pkScript, offset);
}

int _writeTxWitness(
    ByteData buf, int version, List<Uint8List> wit, int offset) {
  offset = writeVarInt(buf, wit.length, offset);
  for (var i = 0; i < wit.length; i++) {
    offset = writeVarBytes(buf, wit[i], offset);
  }

  return offset;
}
