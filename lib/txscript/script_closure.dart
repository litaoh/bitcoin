part of bitcoin.txscript;

class ScriptClosure {
  final Function _getScript;
  ScriptClosure(this._getScript);

  Uint8List getScript(utils.Address addr) {
    return _getScript(addr);
  }
}
