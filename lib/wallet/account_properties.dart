part of bitcoins.wallet;

/// AccountProperties
class AccountProperties {
  final int lastUsedExternalIndex;
  final int lastUsedInternalIndex;
  final int lastReturnedExternalIndex;
  final int lastReturnedInternalIndex;

  AccountProperties({
    this.lastUsedExternalIndex,
    this.lastUsedInternalIndex,
    this.lastReturnedExternalIndex,
    this.lastReturnedInternalIndex,
  });
}
