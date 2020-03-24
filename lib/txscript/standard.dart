part of bitcoin.txscript;

const int MAX_DATA_CARRIER_SIZE = 256;

const int NON_STANDARD_TY = 0;

/// None of the recognized forms.
const int PUB_KEY_TY = 1;

/// Pay pubkey.
const int PUB_KEY_HASH_TY = 2;

const int WITNESS_V0_PUB_KEY_HASH_TY = 3;

/// Pay pubkey hash.
const int SCRIPT_HASH_TY = 4;

const int WITNESS_V0_SCRIPT_HASH_TY = 5;

/// Multi signature.
const int NULL_DATA_TY = 7;

/// isSmallInt returns whether or not the opcode is considered a small integer,
/// which is an OP_0, or OP_1 through OP_16.
bool isSmallInt(OpCode op) {
  if (op.value == OP_0 || (op.value >= OP_1 && op.value <= OP_16)) {
    return true;
  }
  return false;
}
/// asSmallInt returns the passed opcode, which must be true according to
/// isSmallInt(), as an integer.
int asSmallInt(OpCode op) {
  if (op.value == OP_0) {
    return 0;
  }

  return op.value - (OP_1 - 1);
}

/// _payToPubKeyHashScript creates a new script to pay a transaction
/// output to a 20-byte pubkey hash. It is expected that the input is a valid
/// hash.
Uint8List _payToPubKeyHashScript(Uint8List pubKeyHash) {
  return ScriptBuilder()
      .add(OP_DUP)
      .add(OP_HASH160)
      .addData(pubKeyHash)
      .add(OP_EQUALVERIFY)
      .add(OP_CHECKSIG)
      .script();
}

/// _payToWitnessPubKeyHashScript creates a new script to pay to a version 0
/// pubkey hash witness program. The passed hash is expected to be valid.
Uint8List _payToWitnessPubKeyHashScript(Uint8List pubKeyHash) {
  return ScriptBuilder().add(OP_0).addData(pubKeyHash).script();
}

/// payToWitnessScriptHashScript creates a new script to pay to a version 0
/// script hash witness program. The passed hash is expected to be valid.
Uint8List payToWitnessScriptHashScript(Uint8List scriptHash) {
  return ScriptBuilder().add(OP_0).addData(scriptHash).script();
}

/// _payToScriptHashScript creates a new script to pay a transaction output to a
/// script hash. It is expected that the input is a valid hash.
Uint8List _payToScriptHashScript(Uint8List hash) {
  return ScriptBuilder().add(OP_HASH160).addData(hash).add(OP_EQUAL).script();
}

/// payToAddrScript creates a new script to pay a transaction output to a the
/// specified address.
Uint8List payToAddrScript(utils.Address addr) {
  if (addr is utils.AddressPubKeyHash) {
    return _payToPubKeyHashScript(addr.scriptAddress());
  } else if (addr is utils.AddressScriptHash) {
    return _payToScriptHashScript(addr.scriptAddress());
  } else if (addr is utils.AddressWitnessPubKeyHash) {
    return _payToWitnessPubKeyHashScript(addr.scriptAddress());
  }
  throw FormatException(
      'unable to generate payment script for unsupported address type');
}
/// isPubkey returns true if the script passed is a pay-to-pubkey transaction,
/// false otherwise.
bool isPubkey(List<ParsedOpcode> pops) {
  /// Valid pubkeys are either 33 or 65 bytes.
  return pops.length == 2 &&
      (pops[0].data.length == 33 || pops[0].data.length == 65) &&
      pops[1].opcode.value == OP_CHECKSIG;
}
/// isPubkeyHash returns true if the script passed is a pay-to-pubkey-hash
/// transaction, false otherwise.
bool isPubkeyHash(List<ParsedOpcode> pops) {
  return pops.length == 5 &&
      pops[0].opcode.value == OP_DUP &&
      pops[1].opcode.value == OP_HASH160 &&
      pops[2].opcode.value == OP_DATA_20 &&
      pops[3].opcode.value == OP_EQUALVERIFY &&
      pops[4].opcode.value == OP_CHECKSIG;
}
/// isNullData returns true if the passed script is a null data transaction,
/// false otherwise.
bool isNullData(List<ParsedOpcode> pops) {
  var l = pops.length;
  if (l == 1 && pops[0].opcode.value == OP_RETURN) {
    return true;
  }

  return l == 2 &&
      pops[0].opcode.value == OP_RETURN &&
      (isSmallInt(pops[1].opcode) || pops[1].opcode.value <= OP_PUSHDATA4) &&
      pops[1].data.length <= MAX_DATA_CARRIER_SIZE;
}
/// scriptType returns the type of the script being inspected from the known
/// standard types.
int _typeOfScript(List<ParsedOpcode> pops) {
  if (isPubkey(pops)) {
    return PUB_KEY_TY;
  } else if (isPubkeyHash(pops)) {
    return PUB_KEY_HASH_TY;
  } else if (isWitnessPubKeyHash(pops)) {
    return WITNESS_V0_PUB_KEY_HASH_TY;
  } else if (isScriptHash(pops)) {
    return SCRIPT_HASH_TY;
  } else if (isWitnessScriptHash(pops)) {
    return WITNESS_V0_SCRIPT_HASH_TY;
  } else if (isNullData(pops)) {
    return NULL_DATA_TY;
  }
  return NON_STANDARD_TY;
}

/// ExtractPkScriptAddrs returns the type of script, addresses and required
/// signatures associated with the passed PkScript.  Note that it only works for
/// 'standard' transaction script types.  Any data such as public keys which are
/// invalid are omitted from the results.
List<dynamic> extractPkScriptAddrs(Uint8List pkScript, chaincfg.Params net) {
  var addrs = <utils.Address>[];
  int requiredSigs;
  List<ParsedOpcode> pops;
  try {
    pops = parseScript(pkScript);
  } catch (_) {
    return [NON_STANDARD_TY, addrs];
  }
  var scriptClass = _typeOfScript(pops);
  switch (scriptClass) {
    case PUB_KEY_HASH_TY:
      requiredSigs = 1;
      addrs.add(utils.AddressPubKeyHash(hash: pops[2].data, net: net));
      break;
    case SCRIPT_HASH_TY:
      requiredSigs = 1;

      addrs.add(utils.AddressScriptHash(scriptHash: pops[1].data, net: net));
      break;
    case WITNESS_V0_PUB_KEY_HASH_TY:
      requiredSigs = 1;
      addrs.add(utils.AddressWitnessPubKeyHash(hash: pops[1].data, net: net));
      break;
  }

  return [scriptClass, addrs, requiredSigs];
}
