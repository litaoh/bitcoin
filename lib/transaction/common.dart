part of bitcoin.transaction;

const int MAX_UINT_8 = 1 << 8 - 1;
const int MAX_UINT_16 = 1 << 16 - 1;
const int MAX_UINT_32 = 1 << 32 - 1;
const int MAX_UINT_64 = 1 << 64 - 1;

/// ReadVarInt reads a variable length integer from r and returns it as a uint64.
List<int> readVarInt(ByteData buf, [int offset = 0]) {
  var discriminant = buf.getUint8(offset);
  offset += 1;
  int rv, min = 0;
  switch (discriminant) {
    case 0xff:
      rv = buf.getUint64(offset, Endian.little);
      offset += 8;
      min = 0x100000000;
      break;
    case 0xfe:
      rv = buf.getUint32(offset);
      offset += 4;
      min = 0x10000;
      break;
    case 0xfd:
      rv = buf.getUint16(offset);
      offset += 2;
      min = 0xfd;
      break;
    default:
      rv = discriminant;
      break;
  }

  if (rv < min) {
    throw FormatException(
        'non-canonical varint ${rv} - discriminant ${discriminant} must encode a value greater than ${min}');
  }

  return [rv, offset];
}

///write var int
int writeVarInt(ByteData buf, int val, [int offset = 0]) {
  if (val < 0xfd) {
    buf.setUint8(offset, val);
    return offset + 1;
  }

  if (val <= MAX_UINT_16) {
    buf.setUint8(offset, 0xfd);
    offset++;
    buf.setUint16(offset, val);
    return offset + 2;
  }

  if (val <= MAX_UINT_32) {
    buf.setUint8(offset, 0xfe);
    offset++;
    buf.setUint32(offset, val);
    return offset + 5;
  }
  buf.setUint32(offset, 0xff);
  offset++;

  buf.setUint64(offset, val);
  return offset + 8;
}

///var int serialize size
int varIntSerializeSize(int val) {
  // The value is small enough to be represented by itself, so it's
  // just 1 byte.
  if (val < 0xfd) {
    return 1;
  }

  // Discriminant 1 byte plus 2 bytes for the uint16.
  if (val <= MAX_UINT_16) {
    return 3;
  }

  // Discriminant 1 byte plus 4 bytes for the uint32.
  if (val <= MAX_UINT_32) {
    return 5;
  }

  // Discriminant 1 byte plus 8 bytes for the uint64.
  return 9;
}

/// write var string
int writeVarString(ByteData buf, String str, [int offset = 0]) {
  offset = writeVarInt(buf, str.length, offset);
  var bytes = Uint8List.fromList(str.codeUnits);
  offset = copyBytes(buf, bytes, offset);

  return offset;
}

/// copy bytes
int copyBytes(ByteData buf, Uint8List bytes, [offset = 0]) {
  for (var i = 0; i < bytes.length; i++) {
    buf.setUint8(offset, bytes[i]);
    offset++;
  }
  return offset;
}

/// write var bytes
int writeVarBytes(ByteData buf, Uint8List bytes, [offset = 0]) {
  offset = writeVarInt(buf, bytes.length, offset);
  return copyBytes(buf, bytes, offset);
}

/// write uint64 little
int writeUInt64LE(ByteData buf, int val, [offset = 0]) {
  buf.setUint64(offset, val, Endian.little);
  return offset += 8;
}

/// write uint64 big
int writeUInt64BE(ByteData buf, int val, [offset = 0]) {
  buf.setUint64(offset, val);
  return offset += 8;
}