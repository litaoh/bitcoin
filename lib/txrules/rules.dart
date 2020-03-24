part of bitcoins.txrules;

const double DEFAULT_RELAY_FEE_PER_KB = 1e-5;

/// feeForSerializeSize calculates the required fee for a transaction of some
/// arbitrary size given a mempool's relay fee policy.
Amount feeForSerializeSize(Amount relayFeePerKb, int txSerializeSize) {
  var relay = relayFeePerKb.toCoin();
  var fee = relay * BigInt.from(txSerializeSize) ~/ BigInt.from(1000);

  if (fee == BigInt.zero && relay > BigInt.zero) {
    fee = relay;
  }
  var max = BigInt.from(MAX_AMOUNT);
  if (fee < BigInt.zero || fee > max) {
    fee = max;
  }

  return Amount.fromUnit(fee);
}

/// getDustThreshold is used to define the amount below which output will be
/// determined as dust. Threshold is determined as 3 times the relay fee.
Amount getDustThreshold(int scriptSize, Amount relayFeePerKb) {
  /// Calculate the total (estimated) cost to the network.  This is
  /// calculated using the serialize size of the output plus the serial
  /// size of a transaction input which redeems it.  The output is assumed
  /// to be compressed P2PKH as this is the most common script type.  Use
  /// the average size of a compressed P2PKH redeem input (148) rather than
  /// the largest possible (txsizes.REDEEM_P2PKH_INPUT_SIZE).
  var totalSize =
      8 + transaction.varIntSerializeSize(scriptSize) + scriptSize + 148;

  var byteFee = relayFeePerKb.toCoin() ~/ BigInt.from(1e3);

  return Amount.fromUnit(BigInt.from(totalSize) * byteFee * BigInt.from(3));
}

/// isDustAmount determines whether a transaction output value and script length would
/// cause the output to be considered dust.  Transactions with dust outputs are
/// not standard and are rejected by mempools with default policies.
bool isDustAmount(Amount amount, int scriptSize, Amount relayFeePerKb) {
  return amount.toCoin() < getDustThreshold(scriptSize, relayFeePerKb).toCoin();
}
