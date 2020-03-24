part of bitcoins.txhelpers;

/// make tx outputs
List<transaction.TxOut> makeTxOutputs(
    List<TransactionDestination> destinations) {
  var outputs = <transaction.TxOut>[];
  for (var i = 0; i < destinations.length; i++) {
    outputs.add(makeTxOutput(destinations[i]));
  }

  return outputs;
}

///TransactionDestination
transaction.TxOut makeTxOutput(TransactionDestination destination) {
  var pkScript =
      txscript.payToAddrScript(utils.decodeAddress(destination.address));
  return transaction.TxOut(value: destination.amount, pkScript: pkScript);
}
