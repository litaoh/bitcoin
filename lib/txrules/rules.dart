part of bitcoins.txrules;

/// default fee
const int DEFAULT_RELAY_FEE_PER_KB = 1000;

/// feeForSerializeSize calculates the required fee for a transaction of some
/// arbitrary size given a mempool's relay fee policy.
Amount feeForSerializeSize(Amount relayFeePerKb, int txSerializeSize) {
  var relay = relayFeePerKb.toCoin();

  var fee = relay * BigInt.from(txSerializeSize) ~/ BigInt.from(1e3);

  if (fee == BigInt.zero && relay > BigInt.zero) {
    fee = relay;
  }
  var max = BigInt.from(MAX_AMOUNT);
  if (fee < BigInt.zero || fee > max) {
    fee = max;
  }
  return Amount(fee);
}

/// isDustAmount determines whether a transaction output value and script length would
/// cause the output to be considered dust.  Transactions with dust outputs are
/// not standard and are rejected by mempools with default policies.
bool isDustAmount(Amount amount, Amount relayFeePerKb) {
  return amount.toCoin() < relayFeePerKb.toCoin();
}
