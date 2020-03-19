part of bitcoin.transaction;

class Utxo {
  final chainhash.Hash txid;
  final Uint8List pubKey;
  final int vout;
  final utils.Amount amount;
  Utxo({this.txid, this.pubKey, this.vout, this.amount});
}
