part of bitcoin.transaction;

/// MaxMessagePayload is the maximum bytes a message can be regardless of other
/// individual limits imposed by messages themselves.
const int MAX_MESSAGE_PAYLOAD = (1024 * 1024 * 32);

/// 32MB
/// TxVersion is the current latest supported transaction version.
const int TX_VERSION = 1;

/// MaxTxInSequenceNum is the maximum sequence number the sequence field
/// of a transaction input can be.
const int MAX_TX_IN_SEQUENCE_NUM = 0xffffffff;

/// MaxPrevOutIndex is the maximum index the index field of a previous
/// outpoint can be.
const int MAX_PREV_OUT_INDEX = 0xffffffff;

/// NoExpiryValue is the value of expiry that indicates the transaction
/// has no expiry.
const int NO_EXPIRY_VALUE = 0;

/// NullValueIn is a null value for an input witness.
const int NULL_VALUE_IN = -1;

/// NullBlockHeight is the null value for an input witness. It references
/// the genesis block.
const int NULL_BLOCK_HEIGHT = 0x00000000;

/// NullBlockIndex is the null transaction index in a block for an input
/// witness.
const int NULL_BLOCK_INDEX = 0xffffffff;

/// DefaultPkScriptVersion is the default pkScript version, referring to
/// extended Demos script.
const int DEFAULT_PK_SCRIPT_VERSION = 0x0000;

/// TxTreeUnknown is the value returned for a transaction tree that is
/// unknown.  This is typically because the transaction has not been
/// inserted into a block yet.
const int TX_TREE_UNKNOWN = -1;

/// TxTreeRegular is the value for a normal transaction tree for a
/// transaction's location in a block.
const int TX_TREE_REGULAR = 0;

/// TxTreeStake is the value for a stake transaction tree for a
/// transaction's location in a block.
const int TX_TREE_STAKE = 1;

/// SequenceLockTimeDisabled is a flag that if set on a transaction
/// input's sequence number, the sequence number will not be interpreted
/// as a relative locktime.
const int SEQUENCE_LOCK_TIME_DISABLED = 1 << 31;

/// SequenceLockTimeIsSeconds is a flag that if set on a transaction
/// input's sequence number, the relative locktime has units of 512
/// seconds.
const int SEQUENCE_LOCK_TIME_IS_SECONDS = 1 << 22;

/// SequenceLockTimeMask is a mask that extracts the relative locktime
/// when masked against the transaction input sequence number.
const int SEQUENCE_LOCK_TIME_MASK = 0x0000ffff;

/// SequenceLockTimeGranularity is the defined time based granularity
/// for seconds-based relative time locks.  When converting from seconds
/// to a sequence number, the value is right shifted by this amount,
/// therefore the granularity of relative time locks in 512 or 2^9
/// seconds.  Enforced relative lock times are multiples of 512 seconds.
const int SEQUENCE_LOCK_TIME_GRANULARITY = 9;

/// minTxInPayload is the minimum payload size for a transaction input.
/// PreviousOutPoint.Hash + PreviousOutPoint.Index 4 bytes +
/// PreviousOutPoint.Tree 1 byte + Varint for SignatureScript length 1
/// byte + Sequence 4 bytes.
const int MIN_TX_IN_PAYLOAD = 11 + chainhash.HASH_SIZE;

/// maxTxInPerMessage is the maximum number of transactions inputs that
/// a transaction which fits into a message could possibly have.
const int MAX_TX_IN_PER_MESSAGE =
    (MAX_MESSAGE_PAYLOAD ~/ MIN_TX_IN_PAYLOAD) + 1;

/// minTxOutPayload is the minimum payload size for a transaction output.
/// Value 8 bytes + Varint for PkScript length 1 byte.
const int MIN_TX_OUT_PAYLOAD = 9;

/// maxTxOutPerMessage is the maximum number of transactions outputs that
/// a transaction which fits into a message could possibly have.
const int MAX_TX_OUT_PER_MESSAGE =
    (MAX_MESSAGE_PAYLOAD ~/ MIN_TX_OUT_PAYLOAD) + 1;

/// minTxPayload is the minimum payload size for any full encoded
/// (prefix and witness transaction). Note that any realistically
/// usable transaction must have at least one input or output, but
/// that is a rule enforced at a higher layer, so it is intentionally
/// not included here.
/// Version 4 bytes + Varint number of transaction inputs 1 byte + Varint
/// number of transaction outputs 1 byte + Varint representing the number
/// of transaction signatures + LockTime 4 bytes + Expiry 4 bytes + min
/// input payload + min output payload.
const int MIN_TX_PAYLOAD = 4 + 1 + 1 + 1 + 4 + 4;

/// TxSerializeFull indicates a transaction be serialized with the prefix
/// and all witness data.
const int TX_SERIALIZE_FULL = 0;

/// TxSerializeNoWitness indicates a transaction be serialized with only
/// the prefix.
const int TX_SERIALIZE_NO_WITNESS = 1;

/// TxSerializeOnlyWitness indicates a transaction be serialized with
/// only the witness data.
const int TX_SERIALIZE_ONLY_WITNESS = 2;

const int DEFAULT_TICKET_FEE_LIMITS = 0x5800;

class MsgTx {
  chainhash.Hash cachedHash;
  int serType;
  int version;
  List<TxIn> txIn;
  List<TxOut> txOut;
  int lockTime;
  int expiry;
  MsgTx(
      {this.cachedHash,
      this.serType,
      this.version,
      this.txIn,
      this.txOut,
      this.lockTime,
      this.expiry});

  void addTxIn(TxIn ti) {
    txIn.add(ti);
  }

  void addTxOut(TxOut to) {
    txOut.add(to);
  }

  int serializeSize() {
    var n = 0;
    switch (serType) {
      case TX_SERIALIZE_NO_WITNESS:

        /// Version 4 bytes + LockTime 4 bytes + Expiry 4 bytes +
        /// Serialized varint size for the number of transaction
        /// inputs and outputs.
        n += 12 +
            varIntSerializeSize(txIn.length) +
            varIntSerializeSize(txOut.length);
        for (var i = 0; i < txIn.length; i++) {
          n += txIn[i].serializeSizePrefix();
        }
        for (var i = 0; i < txOut.length; i++) {
          n += txOut[i].serializeSize();
        }
        break;
      case TX_SERIALIZE_ONLY_WITNESS:

        /// Version 4 bytes + Serialized varint size for the
        /// number of transaction signatures.
        n += 4 + varIntSerializeSize(txIn.length);
        for (var i = 0; i < txIn.length; i++) {
          n += txIn[i].serializeSizeWitness();
        }
        break;
      case TX_SERIALIZE_FULL:

        /// Version 4 bytes + LockTime 4 bytes + Expiry 4 bytes + Serialized
        /// varint size for the number of transaction inputs (x2) and
        /// outputs. The number of inputs is added twice because it's
        /// encoded once in both the witness and the prefix.
        n += 12 +
            varIntSerializeSize(txIn.length) +
            varIntSerializeSize(txIn.length) +
            varIntSerializeSize(txOut.length);
        for (var i = 0; i < txIn.length; i++) {
          n += txIn[i].serializeSizePrefix();
          n += txIn[i].serializeSizeWitness();
        }

        for (var i = 0; i < txOut.length; i++) {
          n += txOut[i].serializeSize();
        }
        break;
    }
    return n;
  }

  int _decodePrefix(ByteData buf, [int offset = 0]) {
    var data = readVarInt(buf, offset);
    var count = data[0];
    offset = data[1];

    if (count > MAX_TX_IN_PER_MESSAGE) {
      throw FormatException(
          'MsgTx._decodePrefix: too many input transactions to fit into max message size [count ${count}, max ${MAX_TX_IN_PER_MESSAGE}]');
    }

    txIn = List<TxIn>(count);

    for (var i = 0; i < count; i++) {
      var ti = TxIn();
      txIn[i] = ti;
      offset = _readTxInPrefix(buf, serType, ti, offset);
    }

    data = readVarInt(buf, offset);
    count = data[0];
    offset = data[1];

    if (count > MAX_TX_OUT_PER_MESSAGE) {
      throw FormatException(
          'MsgTx._decodePrefix: too many output transactions to fit into max message size [count ${count}, max ${MAX_TX_OUT_PER_MESSAGE}]');
    }

    txOut = List<TxOut>(count);
    for (var i = 0; i < count; i++) {
      var to = TxOut();
      txOut[i] = to;
      offset = _readTxOut(buf, to, offset);
    }

    lockTime = buf.getUint32(offset, Endian.little);
    offset += 4;

    expiry = buf.getUint32(offset, Endian.little);
    offset += 4;
    return offset;
  }

  int _decodeWitness(ByteData buf, [int offset = 0, bool isFull = false]) {
    if (!isFull) {
      var data = readVarInt(buf, offset);
      var count = data[0];
      offset = data[1];

      if (count > MAX_TX_IN_PER_MESSAGE) {
        throw FormatException(
            'MsgTx._decodeWitness: too many input transactions to fit into max message size [count ${count}, max ${MAX_TX_IN_PER_MESSAGE}]');
      }

      txIn = List<TxIn>(count);
      for (var i = 0; i < count; i++) {
        var ti = TxIn();
        txIn[i] = ti;
        offset = _readTxInWitness(buf, ti, offset);
      }

      txOut = List<TxOut>(0);
    } else {
      var data = readVarInt(buf, offset);
      var count = data[0];
      offset = data[1];

      if (count != txIn.length) {
        throw FormatException(
            'MsgTx._decodeWitness: non equal witness and prefix txin quantities (witness ${count}, prefix ${txIn.length})');
      }

      if (count > MAX_TX_IN_PER_MESSAGE) {
        throw FormatException(
            'MsgTx._decodeWitness: too many input transactions to fit into max message size [count ${count}, max ${MAX_TX_IN_PER_MESSAGE}]');
      }

      for (var i = 0; i < count; i++) {
        var ti = TxIn();
        offset = _readTxInWitness(buf, ti, offset);
        txIn[i].valueIn = ti.valueIn;
        txIn[i].blockHeight = ti.blockHeight;
        txIn[i].blockIndex = ti.blockIndex;
        txIn[i].signatureScript = ti.signatureScript;
      }
    }

    return offset;
  }

  void decode(ByteData buf, [int offset = 0]) {
    var ver = buf.getUint32(offset, Endian.little);
    offset += 4;
    version = ver & 0xffff;
    serType = ver >> 16;

    switch (serType) {
      case TX_SERIALIZE_NO_WITNESS:
        offset = _decodePrefix(buf, offset);
        break;
      case TX_SERIALIZE_ONLY_WITNESS:
        offset = _decodeWitness(buf, offset, false);
        break;
      case TX_SERIALIZE_FULL:
        offset = _decodePrefix(buf, offset);

        offset = _decodeWitness(buf, offset, true);
        break;
      default:
        throw FormatException('MsgTx.decode: unsupported transaction type');
        break;
    }
  }

  int _encodePrefix(ByteData buf, int offset) {
    var count = txIn.length;

    offset = writeVarInt(buf, count, offset);

    for (var i = 0; i < txIn.length; i++) {
      offset = _writeTxInPrefix(buf, txIn[i], offset);
    }

    count = txOut.length;
    offset = writeVarInt(buf, count, offset);

    for (var i = 0; i < txOut.length; i++) {
      offset = _writeTxOut(buf, version, txOut[i], offset);
    }

    buf.setUint32(offset, lockTime, Endian.little);
    offset += 4;
    buf.setUint32(offset, expiry, Endian.little);
    offset += 4;
    return offset;
  }

  int _encodeWitness(ByteData buf, int offset) {
    var count = txIn.length;

    offset = writeVarInt(buf, count, offset);

    for (var i = 0; i < txIn.length; i++) {
      var ti = txIn[i];
      offset = _writeTxInWitness(buf, ti, offset);
    }

    return offset;
  }

  void encode(ByteData buf, [int offset = 0]) {
    var serializedVersion = version | serType << 16;

    buf.setUint32(offset, serializedVersion, Endian.little);

    offset += 4;

    switch (serType) {
      case TX_SERIALIZE_NO_WITNESS:
        offset = _encodePrefix(buf, offset);
        break;
      case TX_SERIALIZE_ONLY_WITNESS:
        offset = _encodeWitness(buf, offset);
        break;
      case TX_SERIALIZE_FULL:
        offset = _encodePrefix(buf, offset);

        offset = _encodeWitness(buf, offset);
        break;
      default:
        throw FormatException('MsgTx.encode: unsupported transaction type');
    }
  }

  void serialize(ByteData buf) {
    encode(buf, 0);
  }

  void deserialize(ByteData buf) {
    decode(buf, 0);
  }

  ByteData _serialize(int serType) {
    var txBuf = ByteData(serializeSize());
    serialize(txBuf);

    var mtx = fromBytes(txBuf);
    mtx.serType = serType;
    var buf = ByteData(mtx.serializeSize());
    mtx.serialize(buf);
    return buf;
  }

  ByteData _mustSerialize(serType) {
    return _serialize(serType);
  }

  chainhash.Hash txHash() {
    var buf = _mustSerialize(TX_SERIALIZE_NO_WITNESS);

    return chainhash.hashH(buf.buffer.asUint8List());
  }

  static MsgTx fromBytes(ByteData buf) {
    var msgTx = MsgTx();
    msgTx.deserialize(buf);
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

int _readOutPoint(ByteData buf, TxIn ti, int offset) {
  var hash =
      buf.buffer.asUint8List().sublist(offset, offset + chainhash.HASH_SIZE);

  offset += chainhash.HASH_SIZE;
  var index = buf.getUint32(offset, Endian.little);
  offset += 4;

  ti.previousOutPoint = OutPoint(
      hash: chainhash.Hash(hash), index: index, tree: buf.getUint8(offset));
  offset += 1;

  return offset;
}

int _writeOutPoint(ByteData buf, OutPoint op, int offset) {
  var hash = op.hash.cloneBytes();
  offset = copyBytes(buf, hash, offset);
  buf.setUint32(offset, op.index, Endian.little);

  offset += 4;
  buf.setUint8(offset, op.tree);
  offset += 1;

  return offset;
}

int _readTxInPrefix(ByteData buf, int serType, TxIn ti, int offset) {
  if (serType == TX_SERIALIZE_ONLY_WITNESS) {
    throw FormatException(
        'readTxInPrefix tried to read a prefix input for a witness only tx');
  }

  offset = _readOutPoint(buf, ti, offset);
  ti.sequence = buf.getUint32(offset);
  offset += 4;
  return offset;
}

int _readTxInWitness(ByteData buf, TxIn ti, int offset) {
  ti.valueIn =
      utils.Amount.fromUnit(BigInt.from(buf.getUint64(offset, Endian.little)));
  offset += 8;

  ti.blockHeight = buf.getUint32(offset);
  offset += 4;

  ti.blockIndex = buf.getUint32(offset);
  offset += 4;

  var data = _readScript(
      buf, MAX_MESSAGE_PAYLOAD, offset, 'transaction input signature script');
  ti.signatureScript = data[0];
  offset = data[1];

  return offset;
}

int _writeTxInPrefix(ByteData buf, TxIn ti, int offset) {
  offset = _writeOutPoint(buf, ti.previousOutPoint, offset);
  buf.setUint32(offset, ti.sequence);
  offset += 4;
  return offset;
}

int _writeTxInWitness(ByteData buf, TxIn ti, int offset) {
  buf.setUint64(offset, ti.valueIn.toCoin().toInt(), Endian.little);
  offset += 8;
  buf.setUint32(offset, ti.blockHeight);
  offset += 4;
  buf.setUint32(offset, ti.blockIndex);
  offset += 4;
  offset = writeVarBytes(buf, ti.signatureScript, offset);
  return offset;
}

int _readTxOut(ByteData buf, TxOut to, int offset) {
  var value = buf.getUint64(offset, Endian.little);

  offset += 8;

  to.value = utils.Amount.fromUnit(BigInt.from(value));

  to.version = buf.getUint16(offset);
  offset += 2;
  var data = _readScript(
      buf, MAX_MESSAGE_PAYLOAD, offset, 'transaction output public key script');
  to.pkScript = data[0];
  offset = data[1];

  return offset;
}

int _writeTxOut(ByteData buf, int version, TxOut to, int offset) {
  buf.setUint64(offset, to.value.toCoin().toInt(), Endian.little);
  offset += 8;
  buf.setUint16(offset, to.version);
  offset += 2;

  return writeVarBytes(buf, to.pkScript, offset);
}
