part of bitcoins.transaction;

typedef SelectInputs = InputDetail Function(utils.Amount target);

/// input source
class InputSource {
  final SelectInputs source;
  InputSource(this.source);

  InputDetail selectInputs(utils.Amount target) {
    return source(target);
  }
}
