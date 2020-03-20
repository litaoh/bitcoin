part of bitcoin.transaction;

class TxIn {
  OutPoint previousOutPoint;
  int sequence;
  Uint8List signatureScript;
  List<Uint8List> witness;
  TxIn({
    this.previousOutPoint,
    int sequence,
    List<Uint8List> witness,
    Uint8List signatureScript,
  }) {
    this.witness = witness ?? <Uint8List>[];
    this.sequence = sequence ?? MAX_TX_IN_SEQUENCE_NUM;
    this.signatureScript =
        (signatureScript?.isEmpty ?? true) ? Uint8List(0) : signatureScript;
  }

  /// serializeSize returns the number of bytes it would take to serialize the
  /// the transaction input.
  int serializeSize() {
    /// Outpoint Hash 32 bytes + Outpoint Index 4 bytes + Sequence 4 bytes +
    /// serialized varint size for the length of SignatureScript +
    /// SignatureScript bytes.4
    return 40 +
        varIntSerializeSize(signatureScript.length) +
        signatureScript.length;
  }

  /// serializeSizeWitness returns the number of bytes it would take to serialize the the
  /// transaction input's witness.
  int serializeSizeWitness() {
    var n = varIntSerializeSize(witness.length);

    /// For each element in the witness, we'll need a varint to signal the
    /// size of the element, then finally the number of bytes the element
    /// itself comprises.
    for (int i = 0; i < witness.length; i++) {
      n += varIntSerializeSize(witness[i].length);
      n += witness[i].length;
    }

    return n;
  }
}
