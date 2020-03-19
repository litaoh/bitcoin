part of bitcoin.transaction;

class OutPoint {
  final chainhash.Hash hash;
  final int index;
  final int tree;
  OutPoint({this.hash, this.index, this.tree});

  @override
  String toString() {
    return '${hash.toString()}:${index}:${tree}';
  }
}
