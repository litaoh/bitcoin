library bitcoin.helpers;

import '../transaction/transaction.dart' show TxOut;
import '../utils/utils.dart' show Amount;

/// return output total amount
Amount sumOutputValues(List<TxOut> outputs) {
  var totalOutput = Amount(0);
  for (var i = 0; i < outputs.length; i++) {
    totalOutput += outputs[i].value;
  }
  return totalOutput;
}

/// return output serialize sizes
int sumOutputSerializeSizes(List<TxOut> outputs) {
  var serializeSize = 0;
  for (var i = 0; i < outputs.length; i++) {
    serializeSize += outputs[i].serializeSize();
  }

  return serializeSize;
}
