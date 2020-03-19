part of bitcoin.txscript;

class Stack {
  List<Uint8List> _stk = <Uint8List>[];
  Stack();

  int depth() {
    return _stk.length;
  }

  Uint8List _nipN(int idx) {
    var sz = _stk.length;
    if (idx < 0 || idx > sz - 1) {
      throw FormatException('index ${idx} is invalid for stack size ${sz}');
    }

    var so = _stk[sz - idx - 1];
    if (idx == 0) {
      _stk = _stk.sublist(0, sz - 1);
    } else if (idx == sz - 1) {
      _stk = _stk.sublist(1);
    } else {
      var s1 = _stk.sublist(sz - idx, sz);

      _stk = _stk.sublist(0, sz - idx - 1);
      _stk.addAll(s1);
    }
    return so;
  }

  Uint8List popByteArray() {
    return _nipN(0);
  }

  void dropN(int n) {
    if (n < 1) {
      throw FormatException('attempt to drop ${n} items from stack');
    }
    for (; n > 0; n--) {
      popByteArray();
    }
  }

  Uint8List peekByteArray(int idx) {
    var sz = _stk.length;
    if (idx < 0 || idx >= sz) {
      throw FormatException('index ${idx} is invalid for stack size ${sz}');
    }

    return _stk[sz - idx - 1];
  }

  void pushByteArray(Uint8List so) {
    _stk.add(so);
  }

  bool popBool() {
    var so = popByteArray();

    return _asBool(so);
  }
}

bool _asBool(Uint8List t) {
  for (var i = 0; i < t.length; i++) {
    if (t[i] != 0) {
      if (i == t.length - 1 && t[i] == 0x80) {
        return false;
      }
      return true;
    }
  }
  return false;
}
