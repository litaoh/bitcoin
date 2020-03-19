part of bitcoin.transaction;

class TxOut {
  utils.Amount value;
  int version;
  Uint8List pkScript;
  TxOut({this.value, this.version, this.pkScript});

  /// returns the number of bytes it would take to serialize the transaction output.
  int serializeSize() {
    /// Value 8 bytes + Version 2 bytes + serialized varint size for
    /// the length of PkScript + PkScript bytes.
    return 8 + 2 + varIntSerializeSize(pkScript.length) + pkScript.length;
  }
}
