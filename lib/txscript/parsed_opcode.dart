part of bitcoin.txscript;

class ParsedOpcode {
  final OpCode opcode;
  Uint8List data;

  ParsedOpcode({this.opcode, Uint8List data}) {
    if (data?.isEmpty ?? true) {
      this.data = Uint8List(0);
    }
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
