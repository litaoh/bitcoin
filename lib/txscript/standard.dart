part of bitcoin.txscript;

const int MAX_DATA_CARRIER_SIZE = 256;

/// Classes of script payment known about in the blockchain.

const int NON_STANDARD_TY = 0;

/// None of the recognized forms.
const int PUB_KEY_TY = 1;

/// Pay pubkey.
const int PUB_KEY_HASH_TY = 2;

/// Pay pubkey hash.
const int SCRIPT_HASH_TY = 3;

/// Pay to script hash.
const int MULTI_SIG_TY = 4;

/// Multi signature.
const int NULL_DATA_TY = 5;

/// Empty data-only (provably prunable).
const int STAKE_SUBMISSION_TY = 6;

/// Stake submission.
const int STAKE_GEN_TY = 7;

/// Stake generation
const int STAKE_REVOCATION_TY = 8;

/// Stake revocation.
const int STAKE_SUB_CHANGE_TY = 9;

/// Change for stake submission tx.
const int PUB_KEY_ALT_TY = 10;

/// Alternative signature pubkey.
const int PUB_KEY_HASH_ALT_TY = 11;

/// Alternative signature pubkey hash.
const int SIDE_CREATE_TY = 12;

/// Side chain create contract tx.
const int SIDE_CALL_TY = 13;

/// Side chain call contract tx.

bool isSmallInt(OpCode op) {
  if (op.value == OP_0 || (op.value >= OP_1 && op.value <= OP_16)) {
    return true;
  }
  return false;
}

int asSmallInt(OpCode op) {
  if (op.value == OP_0) {
    return 0;
  }

  return op.value - (OP_1 - 1);
}
/// payToScriptHashScript creates a new script to pay a transaction output to a
/// script hash. It is expected that the input is a valid hash.
Uint8List _payToScriptHashScript(Uint8List hash){
  return ScriptBuilder().add(OP_HASH160).addData(hash).add(OP_EQUAL).script();
}
/// PayToAddrScript creates a new script to pay a transaction output to a the
/// specified address.
Uint8List payToAddrScript(utils.Address addr){
  if(addr is utils.AddressScriptHash){
    return _payToScriptHashScript(addr.scriptAddress());
  }
  throw FormatException('unable to generate payment script for unsupported address type');
}