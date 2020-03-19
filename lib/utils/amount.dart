part of bitcoin.utils;

/// AtomsPerCent is the number of atomic units in one coin cent.
const int ATOMS_PER_CENT = 1000000;

/// AtomsPerCoin is the number of atomic units in one coin.
const int ATOMS_PER_COIN = 100000000;

/// MaxAmount is the maximum transaction amount allowed in atoms.
/// Demos - Changeme for release
const int MAX_AMOUNT = 210000000;

const int AMOUNT_MEGA_COIN = 6;
const int AMOUNT_KILO_COIN = 3;
const int AMOUNT_COIN = 0;
const int AMOUNT_MILLI_COIN = -3;
const int AMOUNT_MICRO_COIN = -6;
const int AMOUNT_ATOM = -8;

class Amount {
  BigInt _value;
  Amount(double amount) {
    _value = BigInt.from((amount * ATOMS_PER_COIN).ceil());
  }

  Amount.fromUnit(this._value);

  double toUnit([int u = AMOUNT_ATOM]) {
    return _value / BigInt.from(10).pow(u + 8);
  }

  String format(int u) {
    var units = ' ';
    switch (u) {
      case AMOUNT_MEGA_COIN:
        units += 'MBTC';
        break;
      case AMOUNT_KILO_COIN:
        units += 'kBTC';
        break;
      case AMOUNT_COIN:
        units += 'BTC';
        break;
      case AMOUNT_MILLI_COIN:
        units += 'mBTC';
        break;
      case AMOUNT_MICRO_COIN:
        units += 'μBTC';
        break;
      case AMOUNT_ATOM:
        units += 'Atom';
        break;
      default:
        return '1e${u} BTC';
    }
    return toUnit(u).toString() + units;
  }

  BigInt toCoin() {
    return _value;
  }

  @override
  String toString() {
    return format(AMOUNT_COIN);
  }

  int compareTo(Amount other) {
    return _value.compareTo(other.toCoin());
  }

  Uint8List bytes() {
    return intToBytes(_value);
  }

  Amount operator +(Amount other) {
    return Amount.fromUnit(_value + other.toCoin());
  }

  Amount operator -(Amount other) {
    return Amount.fromUnit(_value - other.toCoin());
  }
}
