part of bitcoin.transaction;

class InputDetail {
  final utils.Amount amount;
  final List<TxIn> inputs;
  final List<Uint8List> scripts;
  final List<int> redeemScriptSizes;
  InputDetail({this.amount, this.inputs, this.scripts, this.redeemScriptSizes});
}
