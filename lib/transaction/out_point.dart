part of bitcoin.transaction;

class OutPoint {
  final chainhash.Hash hash;
  final int index;
  OutPoint({
    this.hash,
    this.index,
  });

  @override
  String toString() {
    return '${hash.toString()}:${index}';
  }
}
