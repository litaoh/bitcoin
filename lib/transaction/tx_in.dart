part of bitcoin.transaction;

class TxIn {
  OutPoint previousOutPoint;
  int sequence;
  utils.Amount valueIn;
  int blockHeight;
  int blockIndex;
  Uint8List signatureScript;
  TxIn(
      {this.previousOutPoint,
      this.sequence,
      this.valueIn,
      this.blockHeight,
      this.blockIndex,
      Uint8List signatureScript}) {
    this.signatureScript =
        (signatureScript?.isEmpty ?? true) ? Uint8List(0) : signatureScript;
  }

  /// returns the number of bytes it would take to serialize
  /// the transaction input for a prefix.
  int serializeSizePrefix() {
    /// Outpoint Hash 32 bytes + Outpoint Index 4 bytes + Outpoint Tree 1 byte + Sequence 4 bytes.
    return 41;
  }

  ///
  /// SerializeSizeWitness returns the number of bytes it would take to serialize the
  /// transaction input for a witness.
  int serializeSizeWitness() {
    /// ValueIn (8 bytes) + BlockHeight (4 bytes) + BlockIndex (4 bytes) +
    /// serialized varint size for the length of SignatureScript +
    /// SignatureScript bytes.
    var size = 0;
    var ssLen = signatureScript.length;
    return 8 + 4 + 4 + varIntSerializeSize(ssLen) + ssLen + size;
  }
}
