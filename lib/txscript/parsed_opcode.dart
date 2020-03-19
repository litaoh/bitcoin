part of bitcoin.txscript;

class ParsedOpcode {
  final OpCode opcode;
  Uint8List data;

  ParsedOpcode({this.opcode, Uint8List data}) {
    if (data?.isEmpty ?? true) {
      this.data = Uint8List(0);
    }
  }

  bool isDisabled() {
    switch (opcode.value) {
      case OP_CODESEPARATOR:
        return true;
      default:
        return false;
    }
  }

  bool alwaysIllegal() {
    switch (opcode.value) {
      case OP_VERIF:
      case OP_VERNOTIF:
        return true;
      default:
        return false;
    }
  }

  bool isConditional() {
    switch (opcode.value) {
      case OP_IF:
      case OP_NOTIF:
      case OP_ELSE:
      case OP_ENDIF:
        return true;
      default:
        return false;
    }
  }

  void checkMinimalDataPush() {
    var dataLen = data.length;
    var val = opcode.value;
    var name = opcode.name;

    if (dataLen == 0 && val == OP_0) {
      throw FormatException(
          'zero length data push is encoded with opcode $name instead of OP_0');
    } else if (dataLen == 1 && data[0] >= 1 && data[0] <= 16) {
      if (val != OP_1 + data[0] - 1) {
        throw FormatException(
            'data push of the value ${data[0]} encoded with opcode ${name} instead of OP_${data[0]}');
      }
    } else if (dataLen == 1 && data[0] == 0x81) {
      if (val != OP_1NEGATE) {
        throw FormatException(
            'data push of the value -1 encoded with opcode ${name} instead of OP_1NEGATE');
      }
    } else if (dataLen <= 75) {
      if (val != dataLen) {
        throw FormatException(
            'data push of ${dataLen} bytes encoded with opcode ${name} instead of OP_DATA_${dataLen}');
      }
    } else if (dataLen <= 255) {
      if (val != OP_PUSHDATA1) {
        throw FormatException(
            'data push of ${dataLen} bytes encoded with opcode ${name} instead of OP_PUSHDATA1');
      }
    } else if (dataLen <= 65535) {
      if (val != OP_PUSHDATA2) {
        throw FormatException(
            'data push of ${dataLen} bytes encoded with opcode ${name} instead of OP_PUSHDATA2');
      }
    }
  }

  String print(bool oneline) {
    var name = opcode.name;
    if (oneline) {
      if (opcodeOnelineRepls.containsKey(name)) {
        name = opcodeOnelineRepls[name];
      }

      // Nothing more to do for non-data push opcodes.
      if (opcode.length == 1) {
        return name;
      }

      return utils.bytesToHex(data);
    }
    if (opcode.length == 1) {
      return name;
    }

    var retString = name;
    switch (opcode.length) {
      case -1:
        retString += data.length.toString();
        break;
      case -2:
        retString += data.length.toString();
        break;
      case -4:
        retString += data.length.toString();
        break;
    }

    return retString + utils.bytesToHex(data);
  }

  Uint8List bytes() {
    ByteData retbytes;
    if (opcode.length > 0) {
      retbytes = ByteData(opcode.length);
    } else {
      retbytes = ByteData(1 + data.length - opcode.length);
    }

    var offset = 0;
    retbytes.setUint8(offset, opcode.value);
    offset += 1;

    if (opcode.length == 1) {
      return retbytes.buffer.asUint8List();
    }

    var nbytes = opcode.length;
    if (opcode.length < 0) {
      var l = data.length;

      switch (opcode.length) {
        case -1:
          retbytes.setUint8(offset, l);
          offset += 1;
          nbytes = retbytes.getUint8(1) + retbytes.lengthInBytes;
          break;
        case -2:
          retbytes.setUint8(offset, l & 0xff);
          offset += 1;
          retbytes.setUint8(offset, l >> 8 & 0xff);
          offset += 1;
          nbytes = retbytes.getUint16(1) + retbytes.lengthInBytes;
          break;
        case -4:
          retbytes.setUint8(offset, l & 0xff);
          offset += 1;
          retbytes.setUint8(offset, (l >> 8) & 0xff);
          offset += 1;
          retbytes.setUint8(offset, (l >> 16) & 0xff);
          offset += 1;
          retbytes.setUint8(offset, (l >> 24) & 0xff);
          offset += 1;
          nbytes = retbytes.getUint32(1) + retbytes.lengthInBytes;
          break;
      }
    }

    offset = transaction.copyBytes(retbytes, data, offset);

    if (retbytes.lengthInBytes != nbytes) {
      throw FormatException(
          'internal consistency error - parsed opcode ${opcode.name} has data length ${retbytes.lengthInBytes} when ${nbytes} was expected');
    }

    return retbytes.buffer.asUint8List();
  }

  @override
  String toString() {
    return '[${data.join(', ')}]';
  }
}
