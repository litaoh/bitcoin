part of bitcoin.transaction;

class OutPoint {
  final chainhash.Hash hash;
  final int index;
  OutPoint({
    this.hash,
    this.index,
  });

  int get length {
    return hash.length + 4;
  }

  @override
  String toString() {
    return '${hash.toString()}:${index}';
  }
}
