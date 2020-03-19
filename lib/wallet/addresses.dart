part of bitcoin.wallet;

const int DEFAULT_GAP_LIMIT = 20;

const int GAP_POLICY_ERROR = 0;
const int GAP_POLICY_IGNORE = 1;
const int GAP_POLICY_WRAP = 2;

List<hdkeychain.ExtendedKey> _deriveBranches(hdkeychain.ExtendedKey acctXpub) {
  var extKey = acctXpub.child(EXTERNAL_BRANCH);

  var intKey = acctXpub.child(INTERNAL_BRANCH);

  return [extKey, intKey];
}
