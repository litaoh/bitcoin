part of bitcoins.transaction;

class Store {
  final List<Utxo> _utxos = [];
  Store();

  void put(Utxo utxo) {
    _utxos.add(utxo);
  }

  InputSource makeInputSource() {
    if (_utxos.isEmpty) {
      throw FormatException('Utxo is empty.');
    }
    var currentTotal = utils.Amount(BigInt.zero);
    var currentInputs = <TxIn>[];
    var inputValues = <utils.Amount>[];
    var currentScripts = <Uint8List>[];

    return InputSource((utils.Amount target) {
      for (var i = 0; i < _utxos.length; i++) {
        var utxo = _utxos[i];
        var amt = utxo.amount;
        var pkScript = utxo.pubKey;

        var hash = utxo.txid;
        inputValues.add(amt);
        var txIn = TxIn(
          previousOutPoint: OutPoint(hash: hash, index: utxo.vout),
//          valueIn: utxo.amount,
        );

        currentTotal += amt;
        currentScripts.add(pkScript);
        currentInputs.add(txIn);
      }
      _utxos.clear();
      return InputDetail(
        amount: currentTotal,
        inputs: currentInputs,
        inputValues: inputValues,
        scripts: currentScripts,
      );
    });
  }
}
