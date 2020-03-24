part of bitcoins.txscript;

/// MaxStackSize is the maximum combined height of stack and alt stack
/// during execution.
const int MAX_STACK_SIZE = 1024;

/// MaxScriptSize is the maximum allowed length of a raw script.
const int MAX_SCRIPT_SIZE = 16384;

/// DefaultScriptVersion is the default scripting language version
/// representing extended Demos script.
const int DEFAULT_SCRIPT_VERSION = 0;

class ScriptBuilder {
  List<int> _script;
  ScriptBuilder({Uint8List script}) {
    _script = script?.isEmpty ?? true ? <int>[] : script.toList();
  }

  ScriptBuilder add(int code) {
    if (_script.length + 1 > MAX_SCRIPT_SIZE) {
      throw FormatException(
          'adding an opcode would exceed the maximum allowed canonical script length of $MAX_SCRIPT_SIZE');
    }
    _script.add(code);
    return this;
  }

  ScriptBuilder addOps(List<int> opcodes) {
    if (_script.length + opcodes.length > MAX_SCRIPT_SIZE) {
      throw FormatException(
          'adding opcodes would exceed the maximum allowed canonical script length of $MAX_SCRIPT_SIZE');
    }
    _script.addAll(opcodes);
    return this;
  }

  ScriptBuilder addData(Uint8List data) {
    var dataSize = _canonicalDataSize(data);
    if (_script.length + dataSize > MAX_STACK_SIZE) {
      throw FormatException(
          'adding $dataSize bytes of data would exceed the maximum allowed canonical script length of $MAX_STACK_SIZE');
    }
    var dataLen = data.length;
    if (dataLen > MAX_SCRIPT_ELEMENT_SIZE) {
      throw FormatException(
          'adding a data element of $dataLen bytes would exceed the maximum allowed script element size of $MAX_SCRIPT_ELEMENT_SIZE');
    }
    return _addData(data);
  }

  ScriptBuilder _addData(Uint8List data) {
    var dataLen = data.length;
    if (dataLen == 0 || dataLen == 1 && data[0] == 0) {
      _script.add(OP_0);
      return this;
    } else if (dataLen == 1 && data[0] <= 16) {
      _script.add(OP_1 - 1 + data[0]);
      return this;
    } else if (dataLen == 1 && data[0] == 0x81) {
      _script.add(OP_1NEGATE);
      return this;
    }

    if (dataLen < OP_PUSHDATA1) {
      _script.add((OP_DATA_1 - 1) + dataLen);
    } else if (dataLen <= 0xff) {
      _script.add(OP_PUSHDATA1);
      _script.add(dataLen);
    } else if (dataLen <= 0xffff) {
      _script.add(OP_PUSHDATA2);
      _script.add(dataLen & 0xff);
      _script.add((dataLen >> 8) & 0xff);
    } else {
      _script.add(dataLen & 0xff);
      _script.add((dataLen >> 8) & 0xff);
      _script.add((dataLen >> 16) & 0xff);
      _script.add((dataLen >> 24) & 0xff);
      _script.add(OP_PUSHDATA4);
    }
    _script.addAll(data);
    return this;
  }

  void reset() {
    _script.clear();
  }

  Uint8List script() {
    return Uint8List.fromList(_script);
  }
}

/// _canonicalDataSize returns the number of bytes the canonical encoding of the
/// data will take.
int _canonicalDataSize(data) {
  int dataLen = data.length;
  if (dataLen == 0) {
    return 1;
  } else if (dataLen == 1 && data[0] <= 16) {
    return 1;
  } else if (dataLen == 1 && data[0] == 0x81) {
    return 1;
  }
  if (dataLen < OP_PUSHDATA1) {
    return 1 + dataLen;
  } else if (dataLen <= 0xff) {
    return 2 + dataLen;
  } else if (dataLen <= 0xffff) {
    return 3 + dataLen;
  }

  return 5 + dataLen;
}
