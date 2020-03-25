part of bitcoins.transaction;

typedef SelectInputs = InputDetail Function(utils.Amount target);

class InputSource {
  final SelectInputs source;
  InputSource(this.source);

  InputDetail selectInputs(utils.Amount target) {
    return source(target);
  }
}
