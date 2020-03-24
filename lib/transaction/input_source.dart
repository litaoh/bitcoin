part of bitcoin.transaction;

typedef InputDetail SelectInputs(utils.Amount target);

class InputSource {
  final SelectInputs source;
  InputSource(this.source);

  InputDetail selectInputs(utils.Amount target) {
    return source(target);
  }
}
