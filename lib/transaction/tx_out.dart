part of bitcoins.transaction;

class TxOut {
  utils.Amount value;
  Uint8List pkScript;
  TxOut({this.value, this.pkScript});

  /// returns the number of bytes it would take to serialize the transaction output.
  int serializeSize() {
    /// Value 8 bytes + serialized varint size for the length of PkScript +
    /// PkScript bytes.
    return 8 + varIntSerializeSize(pkScript.length) + pkScript.length;
  }
}
