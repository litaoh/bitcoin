part of bitcoin.txscript;

/// MaxStackSize is the maximum combined height of stack and alt stack
/// during execution.
const int MAX_STACK_SIZE = 1024;

/// MaxScriptSize is the maximum allowed length of a raw script.
const int MAX_SCRIPT_SIZE = 16384;

/// DefaultScriptVersion is the default scripting language version
/// representing extended Demos script.
const int DEFAULT_SCRIPT_VERSION = 0;

const int SCRIPT_DISCOURAGE_UPGRADABLE_NOPS = 1;
const int SCRIPT_VERIFY_CHECK_LOCK_TIME_VERIFY = 2;
const int SCRIPT_VERIFY_CHECK_SEQUENCE_VERIFY = 4;
const int SCRIPT_VERIFY_CLEAN_STACK = 8;
const int SCRIPT_VERIFY_SIG_PUSH_ONLY = 16;
const int SCRIPT_VERIFY_SHA256 = 32;

class Engine {
  int _flags;
  int _version;
  int _scriptIdx;
  List<List<ParsedOpcode>> _scripts;
  bool _bip16 = false;
  int _scriptOff;
  Stack _dstack;
  Stack _astack;
  int _numOps;

  List<Uint8List> _savedFirstStack;
  Engine({
    Uint8List scriptPubKey,
    transaction.MsgTx tx,
    int txIdx,
    int flags,
    int scriptVersion,
  }) {
    if (txIdx < 0 || txIdx >= tx.txIn.length) {
      throw FormatException(
          'transaction input index ${txIdx} is negative or >= ${tx.txIn.length}');
    }

    var scriptSig = tx.txIn[txIdx].signatureScript;

    if ((scriptSig?.isEmpty ?? true) && (scriptPubKey?.isEmpty ?? true)) {
      throw FormatException('false stack entry at end of script execution');
    }
    _scriptIdx = 0;
    _flags = flags;
    _version = scriptVersion;

    if (_hasFlag(SCRIPT_VERIFY_SIG_PUSH_ONLY)) {
      throw FormatException('signature script is not push only');
    }

    var scripts = <Uint8List>[scriptSig, scriptPubKey];

    _scripts = List<List<ParsedOpcode>>(scripts.length);
    for (var i = 0; i < scripts.length; i++) {
      var scr = scripts[i];
      if (scr.length > MAX_SCRIPT_SIZE) {
        throw FormatException(
            'script size ${scr.length} is larger than max allowed size ${MAX_SCRIPT_SIZE}');
      }
      _scripts[i] = parseScript(scr);
    }

    if (scripts[0]?.isEmpty ?? true) {
      _scriptIdx++;
    }

    _scriptOff = 0;
    _dstack = Stack();
    _astack = Stack();
    _numOps = 0;
  }

  Stack get dstack => _dstack;

  bool _hasFlag(int flag) {
    return _flags & flag > 0;
  }

  void _validPC() {
    if (_scriptIdx >= _scripts.length) {
      throw FormatException(
          'past input scripts ${_scriptIdx}:${_scriptOff} ${_scripts.length}:xxxx');
    }

    if (_scriptOff >= _scripts[_scriptIdx].length) {
      throw FormatException(
          'past input scripts ${_scriptIdx}:${_scriptOff} ${_scriptIdx}:${_scripts[_scriptIdx]?.length ?? 0}');
    }
  }

  String _disasm(int scriptIdx, int scriptOff) {
    return '${scriptIdx}:${scriptOff}:${_scripts[scriptIdx][scriptOff].print(false)}';
  }

  String _disasmPC() {
    _validPC();
    return _disasm(_scriptIdx, _scriptOff);
  }

  bool _isBranchExecuting() {
    return true;
  }

  void _executeOpcode(ParsedOpcode pop) {
    if (pop.isDisabled()) {
      throw FormatException(
          'attempt to execute disabled opcode ${pop.opcode.name}');
    }

    if (pop.alwaysIllegal()) {
      throw FormatException(
          'attempt to execute reserved opcode ${pop.opcode.name}');
    }

    if (pop.opcode.value > OP_16) {
      _numOps++;
      if (_numOps > MAX_OPS_PER_SCRIPT) {
        throw FormatException(
            'exceeded max operation limit of ${MAX_OPS_PER_SCRIPT}');
      }
    } else if (pop.data.length > MAX_SCRIPT_ELEMENT_SIZE) {
      throw FormatException(
          'element size ${pop.data.length} exceeds max allowed size ${MAX_SCRIPT_ELEMENT_SIZE}');
    }

    if (!_isBranchExecuting() && !pop.isConditional()) {
      return;
    }

    if (_isBranchExecuting() &&
        pop.opcode.value >= 0 &&
        pop.opcode.value <= OP_PUSHDATA4) {
      pop.checkMinimalDataPush();
    }

    pop.opcode.opfunc(pop, this);
  }

  String _disasmScript(int idx) {
    if (idx >= _scripts.length) {
      throw FormatException(
          'script index ${idx} >= total scripts ${_scripts.length}');
    }

    var disstr = '';
    for (var i = 0; i < _scripts[idx].length; i++) {
      disstr += _disasm(idx, i) + '\n';
    }

    return disstr;
  }

  void _checkErrorCondition(bool finalScript) {
    if (_scriptIdx < _scripts.length) {
      throw FormatException('error check when script unfinished');
    }

    if (finalScript &&
        _hasFlag(SCRIPT_VERIFY_CLEAN_STACK) &&
        _dstack.depth() != 1) {
      throw FormatException(
          'stack contains ${_dstack.depth() - 1} unexpected items');
    } else if (_dstack.depth() < 1) {
      throw FormatException('stack empty at end of script execution');
    }

    var v = _dstack.popBool();

    if (!v) {
      String dis0, dis1;
      try {
        dis0 = _disasmScript(0);
      } catch (_) {}

      try {
        dis1 = _disasmScript(1);
      } catch (_) {}

      print('scripts failed:\nscript0: ${dis0}\nscript1: ${dis1}');

      throw FormatException('false stack entry at end of script execution');
    }
  }

  bool _step() {
    // Verify that it is pointing to a valid script address.
    _validPC();

    var po = _scripts[_scriptIdx][_scriptOff];

    _executeOpcode(po);

    var combinedStackSize = _dstack.depth() + _astack.depth();
    if (combinedStackSize > MAX_STACK_SIZE) {
      throw FormatException(
          'combined stack size ${combinedStackSize} > max allowed ${MAX_STACK_SIZE}');
    }

    _scriptOff++;
    if (_scriptOff >= _scripts[_scriptIdx].length) {
      try {
        _astack.dropN(_astack.depth());
      } catch (_) {}

      _numOps = 0;
      _scriptOff = 0;
      if (_scriptIdx == 0 && _bip16) {
        _scriptIdx++;
        _savedFirstStack = _getStack(_dstack);
      } else if (_scriptIdx == 1 && _bip16) {
        _scriptIdx++;
        _checkErrorCondition(false);
        var script = _savedFirstStack[_savedFirstStack.length - 1];
        var pops = parseScript(script);

        _scripts.add(pops);

        _setStack(_dstack, _savedFirstStack);
      } else {
        _scriptIdx++;
      }
      if (_scriptIdx < _scripts.length &&
          _scriptOff >= _scripts[_scriptIdx].length) {
        _scriptIdx++;
      }

      if (_scriptIdx >= _scripts.length) {
        return true;
      }
    }
    return false;
  }

  String execute() {
    if (_version != DEFAULT_SCRIPT_VERSION) {
      return '';
    }
    var done = false;

    while (!done) {
      try {
        print('stepping: ${_disasmPC()}');
      } catch (e) {
        print('stepping: $e');
      }

      done = _step();

      String dstr, astr;

      if (_dstack.depth() != 0) {
        dstr = 'Stack:\n' + _dstack.toString();
      }
      if (_astack.depth() != 0) {
        astr = 'AltStack:\n' + _astack.toString();
      }

      return '${dstr}\n${astr}';
    }

    _checkErrorCondition(true);
    return '';
  }
}

/// get stack
List<Uint8List> _getStack(Stack stack) {
  var arr = List<Uint8List>(stack.depth());

  for (var i = 0; i < arr.length; i++) {
    try {
      arr[arr.length - i - 1] = stack.peekByteArray(i);
    } catch (_) {}
  }

  return arr;
}

/// set stack
void _setStack(Stack stack, List<Uint8List> data) {
  try {
    stack.dropN(stack.depth());
  } catch (_) {}
  for (var i = 0; i < data.length; i++) {
    stack.pushByteArray(data[i]);
  }
}
