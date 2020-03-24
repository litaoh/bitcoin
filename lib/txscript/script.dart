part of bitcoins.txscript;

/// Multisig can't have more sigs than this.
const int MAX_SCRIPT_ELEMENT_SIZE = 2048;

/// _parseScriptTemplate is the same as parseScript but allows the passing of the
/// template list for testing purposes.  When there are parse errors, it returns
/// the list of parsed opcodes up to the point of failure along with the error.
List<ParsedOpcode> _parseScriptTemplate(
    Uint8List script, Map<int, OpCode> opcodes) {
  var retScript = <ParsedOpcode>[];

  for (var i = 0; i < script.length;) {
    var instr = script[i];
    var op = opcodes[instr];
    var pop = ParsedOpcode(opcode: op);
    var len = op.length;
    if (len == 1) {
      i++;
    } else if (len > 1) {
      var scrLen = script.sublist(i).length;
      if (scrLen < op.length) {
        throw FormatException(
            'opcode ${op.name} requires ${op.length} bytes, but script only has ${scrLen} remaining');
      }

      pop.data = script.sublist(i + 1, i + op.length);
      i += op.length;
    } else if (len < 0) {
      int l;
      var off = i + 1;
      var offScr = script.sublist(off);
      if (offScr.length < -op.length) {
        throw FormatException(
            'opcode ${op.name} requires ${-op.length} bytes, but script only has ${offScr.length} remaining');
      }

      switch (op.length) {
        case -1:
          l = script[off];
          break;
        case -2:
          l = ((script[off + 1] << 8) | script[off]);
          break;
        case -4:
          l = ((script[off + 3] << 24) |
              (script[off + 2] << 16) |
              (script[off + 1] << 8) |
              script[off]);
          break;
        default:
          throw FormatException('invalid opcode length ${op.length}');
      }

      off += -op.length;

      if (l > offScr.length || l < 0) {
        throw FormatException(
            'opcode ${op.name} pushes ${l} bytes, but script only has ${offScr.length} remaining');
      }

      pop.data = script.sublist(off, off + l);
      i += 1 - op.length + l;
    }

    retScript.add(pop);
  }

  return retScript;
}

/// parseScript preparses the script in bytes into a list of ParsedOpcodes while
/// applying a number of sanity checks.
List<ParsedOpcode> parseScript(Uint8List script) {
  return _parseScriptTemplate(script, opcodeArray);
}

/// unparseScript reversed the action of parseScript and returns the
/// ParsedOpcodes as a list of bytes
Uint8List unparseScript(List<ParsedOpcode> pops) {
  var script = <int>[];
  for (var i = 0; i < pops.length; i++) {
    var pop = pops[i];
    script.addAll(pop.bytes());
  }
  return Uint8List.fromList(script);
}

List<ParsedOpcode> removeOpcode(List<ParsedOpcode> pkscript, int val) {
  pkscript.removeWhere((ParsedOpcode pop) {
    if (pop.opcode.value == val) {
      return true;
    }
    return false;
  });

  return pkscript;
}

/// isScriptHash returns true if the script passed is a pay-to-script-hash
/// transaction, false otherwise.
bool isScriptHash(List<ParsedOpcode> pops) {
  return pops.length == 3 &&
      pops[0].opcode.value == OP_HASH160 &&
      pops[1].opcode.value == OP_DATA_20 &&
      pops[2].opcode.value == OP_EQUAL;
}

/// isPayToScriptHash returns true if the script is in the standard
/// pay-to-script-hash (P2SH) format, false otherwise.
bool isPayToScriptHash(Uint8List script) {
  return isScriptHash(parseScript(script));
}

/// isWitnessScriptHash returns true if the passed script is a
/// pay-to-witness-script-hash transaction, false otherwise.
bool isWitnessScriptHash(List<ParsedOpcode> pops) {
  return pops.length == 2 &&
      pops[0].opcode.value == OP_0 &&
      pops[1].opcode.value == OP_DATA_32;
}

/// isPayToWitnessScriptHash returns true if the is in the standard
/// pay-to-witness-script-hash (P2WSH) format, false otherwise.
bool isPayToWitnessScriptHash(Uint8List script) {
  return isWitnessScriptHash(parseScript(script));
}

/// isPayToWitnessPubKeyHash returns true if the is in the standard
/// pay-to-witness-pubkey-hash (P2WKH) format, false otherwise.
bool isPayToWitnessPubKeyHash(Uint8List script) {
  return isWitnessPubKeyHash(parseScript(script));
}

/// isWitnessPubKeyHash returns true if the passed script is a
/// pay-to-witness-pubkey-hash, and false otherwise.
bool isWitnessPubKeyHash(List<ParsedOpcode> pops) {
  return pops.length == 2 &&
      pops[0].opcode.value == OP_0 &&
      pops[1].opcode.value == OP_DATA_20;
}
