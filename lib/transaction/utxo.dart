part of bitcoins.transaction;

class Utxo {
  chainhash.Hash txid;
  int vout;
  utils.Amount amount;
  Uint8List pubKey;

  Utxo({
    this.txid,
    this.vout,
    this.amount,
    this.pubKey,
  });

  Utxo.fromJSON(Map<String, dynamic> json) {
    txid = chainhash.Hash.fromString(json['txid'] as String);
    vout = json['vout'] as int;
    amount = utils.Amount(BigInt.parse(json['amount'].toString()));
    pubKey = utils.hexToBytes(json['pubKey']);
  }
}
