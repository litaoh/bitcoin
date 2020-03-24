part of bitcoins.txscript;

/// An opcode defines the information related to a txscript opcode.  opfunc, if
/// present, is the function to call to perform the opcode on the script.  The
/// current script is passed in as a slice with the first member being the opcode
/// itself.
class OpCode {
  final int value;
  final String name;
  final int length;
  OpCode({this.value, this.name, this.length});
}

const int OP_0 = 0x00; // 0
const int OP_FALSE = 0x00; // 0 - AKA OP_0
const int OP_DATA_1 = 0x01; // 1
const int OP_DATA_2 = 0x02; // 2
const int OP_DATA_3 = 0x03; // 3
const int OP_DATA_4 = 0x04; // 4
const int OP_DATA_5 = 0x05; // 5
const int OP_DATA_6 = 0x06; // 6
const int OP_DATA_7 = 0x07; // 7
const int OP_DATA_8 = 0x08; // 8
const int OP_DATA_9 = 0x09; // 9
const int OP_DATA_10 = 0x0a; // 10
const int OP_DATA_11 = 0x0b; // 11
const int OP_DATA_12 = 0x0c; // 12
const int OP_DATA_13 = 0x0d; // 13
const int OP_DATA_14 = 0x0e; // 14
const int OP_DATA_15 = 0x0f; // 15
const int OP_DATA_16 = 0x10; // 16
const int OP_DATA_17 = 0x11; // 17
const int OP_DATA_18 = 0x12; // 18
const int OP_DATA_19 = 0x13; // 19
const int OP_DATA_20 = 0x14; // 20
const int OP_DATA_21 = 0x15; // 21
const int OP_DATA_22 = 0x16; // 22
const int OP_DATA_23 = 0x17; // 23
const int OP_DATA_24 = 0x18; // 24
const int OP_DATA_25 = 0x19; // 25
const int OP_DATA_26 = 0x1a; // 26
const int OP_DATA_27 = 0x1b; // 27
const int OP_DATA_28 = 0x1c; // 28
const int OP_DATA_29 = 0x1d; // 29
const int OP_DATA_30 = 0x1e; // 30
const int OP_DATA_31 = 0x1f; // 31
const int OP_DATA_32 = 0x20; // 32
const int OP_DATA_33 = 0x21; // 33
const int OP_DATA_34 = 0x22; // 34
const int OP_DATA_35 = 0x23; // 35
const int OP_DATA_36 = 0x24; // 36
const int OP_DATA_37 = 0x25; // 37
const int OP_DATA_38 = 0x26; // 38
const int OP_DATA_39 = 0x27; // 39
const int OP_DATA_40 = 0x28; // 40
const int OP_DATA_41 = 0x29; // 41
const int OP_DATA_42 = 0x2a; // 42
const int OP_DATA_43 = 0x2b; // 43
const int OP_DATA_44 = 0x2c; // 44
const int OP_DATA_45 = 0x2d; // 45
const int OP_DATA_46 = 0x2e; // 46
const int OP_DATA_47 = 0x2f; // 47
const int OP_DATA_48 = 0x30; // 48
const int OP_DATA_49 = 0x31; // 49
const int OP_DATA_50 = 0x32; // 50
const int OP_DATA_51 = 0x33; // 51
const int OP_DATA_52 = 0x34; // 52
const int OP_DATA_53 = 0x35; // 53
const int OP_DATA_54 = 0x36; // 54
const int OP_DATA_55 = 0x37; // 55
const int OP_DATA_56 = 0x38; // 56
const int OP_DATA_57 = 0x39; // 57
const int OP_DATA_58 = 0x3a; // 58
const int OP_DATA_59 = 0x3b; // 59
const int OP_DATA_60 = 0x3c; // 60
const int OP_DATA_61 = 0x3d; // 61
const int OP_DATA_62 = 0x3e; // 62
const int OP_DATA_63 = 0x3f; // 63
const int OP_DATA_64 = 0x40; // 64
const int OP_DATA_65 = 0x41; // 65
const int OP_DATA_66 = 0x42; // 66
const int OP_DATA_67 = 0x43; // 67
const int OP_DATA_68 = 0x44; // 68
const int OP_DATA_69 = 0x45; // 69
const int OP_DATA_70 = 0x46; // 70
const int OP_DATA_71 = 0x47; // 71
const int OP_DATA_72 = 0x48; // 72
const int OP_DATA_73 = 0x49; // 73
const int OP_DATA_74 = 0x4a; // 74
const int OP_DATA_75 = 0x4b; // 75
const int OP_PUSHDATA1 = 0x4c; // 76
const int OP_PUSHDATA2 = 0x4d; // 77
const int OP_PUSHDATA4 = 0x4e; // 78
const int OP_1NEGATE = 0x4f; // 79
const int OP_RESERVED = 0x50; // 80
const int OP_1 = 0x51; // 81 - AKA const int OP_TRUE
const int OP_TRUE = 0x51; // 81
const int OP_2 = 0x52; // 82
const int OP_3 = 0x53; // 83
const int OP_4 = 0x54; // 84
const int OP_5 = 0x55; // 85
const int OP_6 = 0x56; // 86
const int OP_7 = 0x57; // 87
const int OP_8 = 0x58; // 88
const int OP_9 = 0x59; // 89
const int OP_10 = 0x5a; // 90
const int OP_11 = 0x5b; // 91
const int OP_12 = 0x5c; // 92
const int OP_13 = 0x5d; // 93
const int OP_14 = 0x5e; // 94
const int OP_15 = 0x5f; // 95
const int OP_16 = 0x60; // 96
const int OP_NOP = 0x61; // 97
const int OP_VER = 0x62; // 98
const int OP_IF = 0x63; // 99
const int OP_NOTIF = 0x64; // 100
const int OP_VERIF = 0x65; // 101
const int OP_VERNOTIF = 0x66; // 102
const int OP_ELSE = 0x67; // 103
const int OP_ENDIF = 0x68; // 104
const int OP_VERIFY = 0x69; // 105
const int OP_RETURN = 0x6a; // 106
const int OP_TOALTSTACK = 0x6b; // 107
const int OP_FROMALTSTACK = 0x6c; // 108
const int OP_2DROP = 0x6d; // 109
const int OP_2DUP = 0x6e; // 110
const int OP_3DUP = 0x6f; // 111
const int OP_2OVER = 0x70; // 112
const int OP_2ROT = 0x71; // 113
const int OP_2SWAP = 0x72; // 114
const int OP_IFDUP = 0x73; // 115
const int OP_DEPTH = 0x74; // 116
const int OP_DROP = 0x75; // 117
const int OP_DUP = 0x76; // 118
const int OP_NIP = 0x77; // 119
const int OP_OVER = 0x78; // 120
const int OP_PICK = 0x79; // 121
const int OP_ROLL = 0x7a; // 122
const int OP_ROT = 0x7b; // 123
const int OP_SWAP = 0x7c; // 124
const int OP_TUCK = 0x7d; // 125
const int OP_CAT = 0x7e; // 126
const int OP_SUBSTR = 0x7f; // 127
const int OP_LEFT = 0x80; // 128
const int OP_RIGHT = 0x81; // 129
const int OP_SIZE = 0x82; // 130
const int OP_INVERT = 0x83; // 131
const int OP_AND = 0x84; // 132
const int OP_OR = 0x85; // 133
const int OP_XOR = 0x86; // 134
const int OP_EQUAL = 0x87; // 135
const int OP_EQUALVERIFY = 0x88; // 136
const int OP_RESERVED1 = 0x89; // 137
const int OP_RESERVED2 = 0x8a; // 138
const int OP_1ADD = 0x8b; // 139
const int OP_1SUB = 0x8c; // 140
const int OP_2MUL = 0x8d; // 141
const int OP_2DIV = 0x8e; // 142
const int OP_NEGATE = 0x8f; // 143
const int OP_ABS = 0x90; // 144
const int OP_NOT = 0x91; // 145
const int OP_0NOTEQUAL = 0x92; // 146
const int OP_ADD = 0x93; // 147
const int OP_SUB = 0x94; // 148
const int OP_MUL = 0x95; // 149
const int OP_DIV = 0x96; // 150
const int OP_MOD = 0x97; // 151
const int OP_LSHIFT = 0x98; // 152
const int OP_RSHIFT = 0x99; // 153
const int OP_BOOLAND = 0x9a; // 154
const int OP_BOOLOR = 0x9b; // 155
const int OP_NUMEQUAL = 0x9c; // 156
const int OP_NUMEQUALVERIFY = 0x9d; // 157
const int OP_NUMNOTEQUAL = 0x9e; // 158
const int OP_LESSTHAN = 0x9f; // 159
const int OP_GREATERTHAN = 0xa0; // 160
const int OP_LESSTHANOREQUAL = 0xa1; // 161
const int OP_GREATERTHANOREQUAL = 0xa2; // 162
const int OP_MIN = 0xa3; // 163
const int OP_MAX = 0xa4; // 164
const int OP_WITHIN = 0xa5; // 165
const int OP_RIPEMD160 = 0xa6; // 166
const int OP_SHA1 = 0xa7; // 167
const int OP_SHA256 = 0xa8; // 168
const int OP_HASH160 = 0xa9; // 169
const int OP_HASH256 = 0xaa; // 170
const int OP_CODESEPARATOR = 0xab; // 171
const int OP_CHECKSIG = 0xac; // 172
const int OP_CHECKSIGVERIFY = 0xad; // 173
const int OP_CHECKMULTISIG = 0xae; // 174
const int OP_CHECKMULTISIGVERIFY = 0xaf; // 175
const int OP_NOP1 = 0xb0; // 176
const int OP_NOP2 = 0xb1; // 177
const int OP_CHECKLOCKTIMEVERIFY = 0xb1; // 177 - AKA const int OP_NOP2
const int OP_NOP3 = 0xb2; // 178
const int OP_CHECKSEQUENCEVERIFY = 0xb2; // 178 - AKA const int OP_NOP3
const int OP_NOP4 = 0xb3; // 179
const int OP_NOP5 = 0xb4; // 180
const int OP_NOP6 = 0xb5; // 181
const int OP_NOP7 = 0xb6; // 182
const int OP_NOP8 = 0xb7; // 183
const int OP_NOP9 = 0xb8; // 184
const int OP_NOP10 = 0xb9; // 185
const int OP_UNKNOWN186 = 0xba; // 186
const int OP_UNKNOWN187 = 0xbb; // 187
const int OP_UNKNOWN188 = 0xbc; // 188
const int OP_UNKNOWN189 = 0xbd; // 189
const int OP_UNKNOWN190 = 0xbe; // 190
const int OP_UNKNOWN191 = 0xbf; // 191
const int OP_UNKNOWN192 = 0xc0; // 192
const int OP_UNKNOWN193 = 0xc1; // 193
const int OP_UNKNOWN194 = 0xc2; // 194
const int OP_UNKNOWN195 = 0xc3; // 195
const int OP_UNKNOWN196 = 0xc4; // 196
const int OP_UNKNOWN197 = 0xc5; // 197
const int OP_UNKNOWN198 = 0xc6; // 198
const int OP_UNKNOWN199 = 0xc7; // 199
const int OP_UNKNOWN200 = 0xc8; // 200
const int OP_UNKNOWN201 = 0xc9; // 201
const int OP_UNKNOWN202 = 0xca; // 202
const int OP_UNKNOWN203 = 0xcb; // 203
const int OP_UNKNOWN204 = 0xcc; // 204
const int OP_UNKNOWN205 = 0xcd; // 205
const int OP_UNKNOWN206 = 0xce; // 206
const int OP_UNKNOWN207 = 0xcf; // 207
const int OP_UNKNOWN208 = 0xd0; // 208
const int OP_UNKNOWN209 = 0xd1; // 209
const int OP_UNKNOWN210 = 0xd2; // 210
const int OP_UNKNOWN211 = 0xd3; // 211
const int OP_UNKNOWN212 = 0xd4; // 212
const int OP_UNKNOWN213 = 0xd5; // 213
const int OP_UNKNOWN214 = 0xd6; // 214
const int OP_UNKNOWN215 = 0xd7; // 215
const int OP_UNKNOWN216 = 0xd8; // 216
const int OP_UNKNOWN217 = 0xd9; // 217
const int OP_UNKNOWN218 = 0xda; // 218
const int OP_UNKNOWN219 = 0xdb; // 219
const int OP_UNKNOWN220 = 0xdc; // 220
const int OP_UNKNOWN221 = 0xdd; // 221
const int OP_UNKNOWN222 = 0xde; // 222
const int OP_UNKNOWN223 = 0xdf; // 223
const int OP_UNKNOWN224 = 0xe0; // 224
const int OP_UNKNOWN225 = 0xe1; // 225
const int OP_UNKNOWN226 = 0xe2; // 226
const int OP_UNKNOWN227 = 0xe3; // 227
const int OP_UNKNOWN228 = 0xe4; // 228
const int OP_UNKNOWN229 = 0xe5; // 229
const int OP_UNKNOWN230 = 0xe6; // 230
const int OP_UNKNOWN231 = 0xe7; // 231
const int OP_UNKNOWN232 = 0xe8; // 232
const int OP_UNKNOWN233 = 0xe9; // 233
const int OP_UNKNOWN234 = 0xea; // 234
const int OP_UNKNOWN235 = 0xeb; // 235
const int OP_UNKNOWN236 = 0xec; // 236
const int OP_UNKNOWN237 = 0xed; // 237
const int OP_UNKNOWN238 = 0xee; // 238
const int OP_UNKNOWN239 = 0xef; // 239
const int OP_UNKNOWN240 = 0xf0; // 240
const int OP_UNKNOWN241 = 0xf1; // 241
const int OP_UNKNOWN242 = 0xf2; // 242
const int OP_UNKNOWN243 = 0xf3; // 243
const int OP_UNKNOWN244 = 0xf4; // 244
const int OP_UNKNOWN245 = 0xf5; // 245
const int OP_UNKNOWN246 = 0xf6; // 246
const int OP_UNKNOWN247 = 0xf7; // 247
const int OP_UNKNOWN248 = 0xf8; // 248
const int OP_UNKNOWN249 = 0xf9; // 249
const int OP_SMALLINTEGER = 0xfa; // 250 - bitcoins core internal
const int OP_PUBKEYS = 0xfb; // 251 - bitcoins core internal
const int OP_UNKNOWN252 = 0xfc; // 252
const int OP_PUBKEYHASH = 0xfd; // 253 - bitcoins core internal
const int OP_PUBKEY = 0xfe; // 254 - bitcoins core internal
const int OP_INVALIDOPCODE = 0xff; // 255 - bitcoins core internal

/// Conditional execution constants.
const int OP_COND_FALSE = 0;
const int OP_COND_TRUE = 1;
const int OP_COND_SKIP = 2;

Map<int, OpCode> opcodeArray = <int, OpCode>{
  OP_FALSE: OpCode(
    value: OP_FALSE,
    name: "OP_0",
    length: 1,
  ),
  OP_DATA_1: OpCode(
    value: OP_DATA_1,
    name: "OP_DATA_1",
    length: 2,
  ),
  OP_DATA_2: OpCode(
    value: OP_DATA_2,
    name: "OP_DATA_2",
    length: 3,
  ),
  OP_DATA_3: OpCode(
    value: OP_DATA_3,
    name: "OP_DATA_3",
    length: 4,
  ),
  OP_DATA_4: OpCode(
    value: OP_DATA_4,
    name: "OP_DATA_4",
    length: 5,
  ),
  OP_DATA_5: OpCode(
    value: OP_DATA_5,
    name: "OP_DATA_5",
    length: 6,
  ),
  OP_DATA_6: OpCode(
    value: OP_DATA_6,
    name: "OP_DATA_6",
    length: 7,
  ),
  OP_DATA_7: OpCode(
    value: OP_DATA_7,
    name: "OP_DATA_7",
    length: 8,
  ),
  OP_DATA_8: OpCode(
    value: OP_DATA_8,
    name: "OP_DATA_8",
    length: 9,
  ),
  OP_DATA_9: OpCode(
    value: OP_DATA_9,
    name: "OP_DATA_9",
    length: 10,
  ),
  OP_DATA_10: OpCode(
    value: OP_DATA_10,
    name: "OP_DATA_10",
    length: 11,
  ),
  OP_DATA_11: OpCode(
    value: OP_DATA_11,
    name: "OP_DATA_11",
    length: 12,
  ),
  OP_DATA_12: OpCode(
    value: OP_DATA_12,
    name: "OP_DATA_12",
    length: 13,
  ),
  OP_DATA_13: OpCode(
    value: OP_DATA_13,
    name: "OP_DATA_13",
    length: 14,
  ),
  OP_DATA_14: OpCode(
    value: OP_DATA_14,
    name: "OP_DATA_14",
    length: 15,
  ),
  OP_DATA_15: OpCode(
    value: OP_DATA_15,
    name: "OP_DATA_15",
    length: 16,
  ),
  OP_DATA_16: OpCode(
    value: OP_DATA_16,
    name: "OP_DATA_16",
    length: 17,
  ),
  OP_DATA_17: OpCode(
    value: OP_DATA_17,
    name: "OP_DATA_17",
    length: 18,
  ),
  OP_DATA_18: OpCode(
    value: OP_DATA_18,
    name: "OP_DATA_18",
    length: 19,
  ),
  OP_DATA_19: OpCode(
    value: OP_DATA_19,
    name: "OP_DATA_19",
    length: 20,
  ),
  OP_DATA_20: OpCode(
    value: OP_DATA_20,
    name: "OP_DATA_20",
    length: 21,
  ),
  OP_DATA_21: OpCode(
    value: OP_DATA_21,
    name: "OP_DATA_21",
    length: 22,
  ),
  OP_DATA_22: OpCode(
    value: OP_DATA_22,
    name: "OP_DATA_22",
    length: 23,
  ),
  OP_DATA_23: OpCode(
    value: OP_DATA_23,
    name: "OP_DATA_23",
    length: 24,
  ),
  OP_DATA_24: OpCode(
    value: OP_DATA_24,
    name: "OP_DATA_24",
    length: 25,
  ),
  OP_DATA_25: OpCode(
    value: OP_DATA_25,
    name: "OP_DATA_25",
    length: 26,
  ),
  OP_DATA_26: OpCode(
    value: OP_DATA_26,
    name: "OP_DATA_26",
    length: 27,
  ),
  OP_DATA_27: OpCode(
    value: OP_DATA_27,
    name: "OP_DATA_27",
    length: 28,
  ),
  OP_DATA_28: OpCode(
    value: OP_DATA_28,
    name: "OP_DATA_28",
    length: 29,
  ),
  OP_DATA_29: OpCode(
    value: OP_DATA_29,
    name: "OP_DATA_29",
    length: 30,
  ),
  OP_DATA_30: OpCode(
    value: OP_DATA_30,
    name: "OP_DATA_30",
    length: 31,
  ),
  OP_DATA_31: OpCode(
    value: OP_DATA_31,
    name: "OP_DATA_31",
    length: 32,
  ),
  OP_DATA_32: OpCode(
    value: OP_DATA_32,
    name: "OP_DATA_32",
    length: 33,
  ),
  OP_DATA_33: OpCode(
    value: OP_DATA_33,
    name: "OP_DATA_33",
    length: 34,
  ),
  OP_DATA_34: OpCode(
    value: OP_DATA_34,
    name: "OP_DATA_34",
    length: 35,
  ),
  OP_DATA_35: OpCode(
    value: OP_DATA_35,
    name: "OP_DATA_35",
    length: 36,
  ),
  OP_DATA_36: OpCode(
    value: OP_DATA_36,
    name: "OP_DATA_36",
    length: 37,
  ),
  OP_DATA_37: OpCode(
    value: OP_DATA_37,
    name: "OP_DATA_37",
    length: 38,
  ),
  OP_DATA_38: OpCode(
    value: OP_DATA_38,
    name: "OP_DATA_38",
    length: 39,
  ),
  OP_DATA_39: OpCode(
    value: OP_DATA_39,
    name: "OP_DATA_39",
    length: 40,
  ),
  OP_DATA_40: OpCode(
    value: OP_DATA_40,
    name: "OP_DATA_40",
    length: 41,
  ),
  OP_DATA_41: OpCode(
    value: OP_DATA_41,
    name: "OP_DATA_41",
    length: 42,
  ),
  OP_DATA_42: OpCode(
    value: OP_DATA_42,
    name: "OP_DATA_42",
    length: 43,
  ),
  OP_DATA_43: OpCode(
    value: OP_DATA_43,
    name: "OP_DATA_43",
    length: 44,
  ),
  OP_DATA_44: OpCode(
    value: OP_DATA_44,
    name: "OP_DATA_44",
    length: 45,
  ),
  OP_DATA_45: OpCode(
    value: OP_DATA_45,
    name: "OP_DATA_45",
    length: 46,
  ),
  OP_DATA_46: OpCode(
    value: OP_DATA_46,
    name: "OP_DATA_46",
    length: 47,
  ),
  OP_DATA_47: OpCode(
    value: OP_DATA_47,
    name: "OP_DATA_47",
    length: 48,
  ),
  OP_DATA_48: OpCode(
    value: OP_DATA_48,
    name: "OP_DATA_48",
    length: 49,
  ),
  OP_DATA_49: OpCode(
    value: OP_DATA_49,
    name: "OP_DATA_49",
    length: 50,
  ),
  OP_DATA_50: OpCode(
    value: OP_DATA_50,
    name: "OP_DATA_50",
    length: 51,
  ),
  OP_DATA_51: OpCode(
    value: OP_DATA_51,
    name: "OP_DATA_51",
    length: 52,
  ),
  OP_DATA_52: OpCode(
    value: OP_DATA_52,
    name: "OP_DATA_52",
    length: 53,
  ),
  OP_DATA_53: OpCode(
    value: OP_DATA_53,
    name: "OP_DATA_53",
    length: 54,
  ),
  OP_DATA_54: OpCode(
    value: OP_DATA_54,
    name: "OP_DATA_54",
    length: 55,
  ),
  OP_DATA_55: OpCode(
    value: OP_DATA_55,
    name: "OP_DATA_55",
    length: 56,
  ),
  OP_DATA_56: OpCode(
    value: OP_DATA_56,
    name: "OP_DATA_56",
    length: 57,
  ),
  OP_DATA_57: OpCode(
    value: OP_DATA_57,
    name: "OP_DATA_57",
    length: 58,
  ),
  OP_DATA_58: OpCode(
    value: OP_DATA_58,
    name: "OP_DATA_58",
    length: 59,
  ),
  OP_DATA_59: OpCode(
    value: OP_DATA_59,
    name: "OP_DATA_59",
    length: 60,
  ),
  OP_DATA_60: OpCode(
    value: OP_DATA_60,
    name: "OP_DATA_60",
    length: 61,
  ),
  OP_DATA_61: OpCode(
    value: OP_DATA_61,
    name: "OP_DATA_61",
    length: 62,
  ),
  OP_DATA_62: OpCode(
    value: OP_DATA_62,
    name: "OP_DATA_62",
    length: 63,
  ),
  OP_DATA_63: OpCode(
    value: OP_DATA_63,
    name: "OP_DATA_63",
    length: 64,
  ),
  OP_DATA_64: OpCode(
    value: OP_DATA_64,
    name: "OP_DATA_64",
    length: 65,
  ),
  OP_DATA_65: OpCode(
    value: OP_DATA_65,
    name: "OP_DATA_65",
    length: 66,
  ),
  OP_DATA_66: OpCode(
    value: OP_DATA_66,
    name: "OP_DATA_66",
    length: 67,
  ),
  OP_DATA_67: OpCode(
    value: OP_DATA_67,
    name: "OP_DATA_67",
    length: 68,
  ),
  OP_DATA_68: OpCode(
    value: OP_DATA_68,
    name: "OP_DATA_68",
    length: 69,
  ),
  OP_DATA_69: OpCode(
    value: OP_DATA_69,
    name: "OP_DATA_69",
    length: 70,
  ),
  OP_DATA_70: OpCode(
    value: OP_DATA_70,
    name: "OP_DATA_70",
    length: 71,
  ),
  OP_DATA_71: OpCode(
    value: OP_DATA_71,
    name: "OP_DATA_71",
    length: 72,
  ),
  OP_DATA_72: OpCode(
    value: OP_DATA_72,
    name: "OP_DATA_72",
    length: 73,
  ),
  OP_DATA_73: OpCode(
    value: OP_DATA_73,
    name: "OP_DATA_73",
    length: 74,
  ),
  OP_DATA_74: OpCode(
    value: OP_DATA_74,
    name: "OP_DATA_74",
    length: 75,
  ),
  OP_DATA_75: OpCode(
    value: OP_DATA_75,
    name: "OP_DATA_75",
    length: 76,
  ),
  OP_PUSHDATA1: OpCode(
    value: OP_PUSHDATA1,
    name: "OP_PUSHDATA1",
    length: -1,
  ),
  OP_PUSHDATA2: OpCode(
    value: OP_PUSHDATA2,
    name: "OP_PUSHDATA2",
    length: -2,
  ),
  OP_PUSHDATA4: OpCode(
    value: OP_PUSHDATA4,
    name: "OP_PUSHDATA4",
    length: -4,
  ),
  OP_1NEGATE: OpCode(
    value: OP_1NEGATE,
    name: "OP_1NEGATE",
    length: 1,
  ),
  OP_RESERVED: OpCode(
    value: OP_RESERVED,
    name: "OP_RESERVED",
    length: 1,
  ),
  OP_TRUE: OpCode(
    value: OP_TRUE,
    name: "OP_1",
    length: 1,
  ),
  OP_2: OpCode(
    value: OP_2,
    name: "OP_2",
    length: 1,
  ),
  OP_3: OpCode(
    value: OP_3,
    name: "OP_3",
    length: 1,
  ),
  OP_4: OpCode(
    value: OP_4,
    name: "OP_4",
    length: 1,
  ),
  OP_5: OpCode(
    value: OP_5,
    name: "OP_5",
    length: 1,
  ),
  OP_6: OpCode(
    value: OP_6,
    name: "OP_6",
    length: 1,
  ),
  OP_7: OpCode(
    value: OP_7,
    name: "OP_7",
    length: 1,
  ),
  OP_8: OpCode(
    value: OP_8,
    name: "OP_8",
    length: 1,
  ),
  OP_9: OpCode(
    value: OP_9,
    name: "OP_9",
    length: 1,
  ),
  OP_10: OpCode(
    value: OP_10,
    name: "OP_10",
    length: 1,
  ),
  OP_11: OpCode(
    value: OP_11,
    name: "OP_11",
    length: 1,
  ),
  OP_12: OpCode(
    value: OP_12,
    name: "OP_12",
    length: 1,
  ),
  OP_13: OpCode(
    value: OP_13,
    name: "OP_13",
    length: 1,
  ),
  OP_14: OpCode(
    value: OP_14,
    name: "OP_14",
    length: 1,
  ),
  OP_15: OpCode(
    value: OP_15,
    name: "OP_15",
    length: 1,
  ),
  OP_16: OpCode(
    value: OP_16,
    name: "OP_16",
    length: 1,
  ),

  // Control opcodes.
  OP_NOP: OpCode(
    value: OP_NOP,
    name: "OP_NOP",
    length: 1,
  ),
  OP_VER: OpCode(
    value: OP_VER,
    name: "OP_VER",
    length: 1,
  ),
  OP_IF: OpCode(
    value: OP_IF,
    name: "OP_IF",
    length: 1,
  ),
  OP_NOTIF: OpCode(
    value: OP_NOTIF,
    name: "OP_NOTIF",
    length: 1,
  ),
  OP_VERIF: OpCode(
    value: OP_VERIF,
    name: "OP_VERIF",
    length: 1,
  ),
  OP_VERNOTIF: OpCode(
    value: OP_VERNOTIF,
    name: "OP_VERNOTIF",
    length: 1,
  ),
  OP_ELSE: OpCode(
    value: OP_ELSE,
    name: "OP_ELSE",
    length: 1,
  ),
  OP_ENDIF: OpCode(
    value: OP_ENDIF,
    name: "OP_ENDIF",
    length: 1,
  ),
  OP_VERIFY: OpCode(
    value: OP_VERIFY,
    name: "OP_VERIFY",
    length: 1,
  ),
  OP_RETURN: OpCode(
    value: OP_RETURN,
    name: "OP_RETURN",
    length: 1,
  ),
  OP_CHECKLOCKTIMEVERIFY: OpCode(
    value: OP_CHECKLOCKTIMEVERIFY,
    name: "OP_CHECKLOCKTIMEVERIFY",
    length: 1,
  ),
  OP_CHECKSEQUENCEVERIFY: OpCode(
    value: OP_CHECKSEQUENCEVERIFY,
    name: "OP_CHECKSEQUENCEVERIFY",
    length: 1,
  ),

  // Stack opcodes.
  OP_TOALTSTACK: OpCode(
    value: OP_TOALTSTACK,
    name: "OP_TOALTSTACK",
    length: 1,
  ),
  OP_FROMALTSTACK: OpCode(
    value: OP_FROMALTSTACK,
    name: "OP_FROMALTSTACK",
    length: 1,
  ),
  OP_2DROP: OpCode(
    value: OP_2DROP,
    name: "OP_2DROP",
    length: 1,
  ),
  OP_2DUP: OpCode(
    value: OP_2DUP,
    name: "OP_2DUP",
    length: 1,
  ),
  OP_3DUP: OpCode(
    value: OP_3DUP,
    name: "OP_3DUP",
    length: 1,
  ),
  OP_2OVER: OpCode(
    value: OP_2OVER,
    name: "OP_2OVER",
    length: 1,
  ),
  OP_2ROT: OpCode(
    value: OP_2ROT,
    name: "OP_2ROT",
    length: 1,
  ),
  OP_2SWAP: OpCode(
    value: OP_2SWAP,
    name: "OP_2SWAP",
    length: 1,
  ),
  OP_IFDUP: OpCode(
    value: OP_IFDUP,
    name: "OP_IFDUP",
    length: 1,
  ),
  OP_DEPTH: OpCode(
    value: OP_DEPTH,
    name: "OP_DEPTH",
    length: 1,
  ),
  OP_DROP: OpCode(
    value: OP_DROP,
    name: "OP_DROP",
    length: 1,
  ),
  OP_DUP: OpCode(
    value: OP_DUP,
    name: "OP_DUP",
    length: 1,
  ),
  OP_NIP: OpCode(
    value: OP_NIP,
    name: "OP_NIP",
    length: 1,
  ),
  OP_OVER: OpCode(
    value: OP_OVER,
    name: "OP_OVER",
    length: 1,
  ),
  OP_PICK: OpCode(
    value: OP_PICK,
    name: "OP_PICK",
    length: 1,
  ),
  OP_ROLL: OpCode(
    value: OP_ROLL,
    name: "OP_ROLL",
    length: 1,
  ),
  OP_ROT: OpCode(
    value: OP_ROT,
    name: "OP_ROT",
    length: 1,
  ),
  OP_SWAP: OpCode(
    value: OP_SWAP,
    name: "OP_SWAP",
    length: 1,
  ),
  OP_TUCK: OpCode(
    value: OP_TUCK,
    name: "OP_TUCK",
    length: 1,
  ),

  // Splice opcodes.
  OP_CAT: OpCode(
    value: OP_CAT,
    name: "OP_CAT",
    length: 1,
  ),
  OP_SUBSTR: OpCode(
    value: OP_SUBSTR,
    name: "OP_SUBSTR",
    length: 1,
  ),
  OP_LEFT: OpCode(
    value: OP_LEFT,
    name: "OP_LEFT",
    length: 1,
  ),
  OP_RIGHT: OpCode(
    value: OP_RIGHT,
    name: "OP_RIGHT",
    length: 1,
  ),
  OP_SIZE: OpCode(
    value: OP_SIZE,
    name: "OP_SIZE",
    length: 1,
  ),

  // Bitwise logic opcodes.
  OP_INVERT: OpCode(
    value: OP_INVERT,
    name: "OP_INVERT",
    length: 1,
  ),
  OP_AND: OpCode(
    value: OP_AND,
    name: "OP_AND",
    length: 1,
  ),
  OP_OR: OpCode(
    value: OP_OR,
    name: "OP_OR",
    length: 1,
  ),
  OP_XOR: OpCode(
    value: OP_XOR,
    name: "OP_XOR",
    length: 1,
  ),
  OP_EQUAL: OpCode(
    value: OP_EQUAL,
    name: "OP_EQUAL",
    length: 1,
  ),
  OP_EQUALVERIFY: OpCode(
    value: OP_EQUALVERIFY,
    name: "OP_EQUALVERIFY",
    length: 1,
  ),
  OP_RESERVED1: OpCode(
    value: OP_RESERVED1,
    name: "OP_RESERVED1",
    length: 1,
  ),
  OP_RESERVED2: OpCode(
    value: OP_RESERVED2,
    name: "OP_RESERVED2",
    length: 1,
  ),

  // Numeric related opcodes.
  OP_1ADD: OpCode(
    value: OP_1ADD,
    name: "OP_1ADD",
    length: 1,
  ),
  OP_1SUB: OpCode(
    value: OP_1SUB,
    name: "OP_1SUB",
    length: 1,
  ),
  OP_2MUL: OpCode(
    value: OP_2MUL,
    name: "OP_2MUL",
    length: 1,
  ),
  OP_2DIV: OpCode(
    value: OP_2DIV,
    name: "OP_2DIV",
    length: 1,
  ),
  OP_NEGATE: OpCode(
    value: OP_NEGATE,
    name: "OP_NEGATE",
    length: 1,
  ),
  OP_ABS: OpCode(
    value: OP_ABS,
    name: "OP_ABS",
    length: 1,
  ),
  OP_NOT: OpCode(
    value: OP_NOT,
    name: "OP_NOT",
    length: 1,
  ),
  OP_0NOTEQUAL: OpCode(
    value: OP_0NOTEQUAL,
    name: "OP_0NOTEQUAL",
    length: 1,
  ),
  OP_ADD: OpCode(
    value: OP_ADD,
    name: "OP_ADD",
    length: 1,
  ),
  OP_SUB: OpCode(
    value: OP_SUB,
    name: "OP_SUB",
    length: 1,
  ),
  OP_MUL: OpCode(
    value: OP_MUL,
    name: "OP_MUL",
    length: 1,
  ),
  OP_DIV: OpCode(
    value: OP_DIV,
    name: "OP_DIV",
    length: 1,
  ),
  OP_MOD: OpCode(
    value: OP_MOD,
    name: "OP_MOD",
    length: 1,
  ),
  OP_LSHIFT: OpCode(
    value: OP_LSHIFT,
    name: "OP_LSHIFT",
    length: 1,
  ),
  OP_RSHIFT: OpCode(
    value: OP_RSHIFT,
    name: "OP_RSHIFT",
    length: 1,
  ),
  OP_BOOLAND: OpCode(
    value: OP_BOOLAND,
    name: "OP_BOOLAND",
    length: 1,
  ),
  OP_BOOLOR: OpCode(
    value: OP_BOOLOR,
    name: "OP_BOOLOR",
    length: 1,
  ),
  OP_NUMEQUAL: OpCode(
    value: OP_NUMEQUAL,
    name: "OP_NUMEQUAL",
    length: 1,
  ),
  OP_NUMEQUALVERIFY: OpCode(
    value: OP_NUMEQUALVERIFY,
    name: "OP_NUMEQUALVERIFY",
    length: 1,
  ),
  OP_NUMNOTEQUAL: OpCode(
    value: OP_NUMNOTEQUAL,
    name: "OP_NUMNOTEQUAL",
    length: 1,
  ),
  OP_LESSTHAN: OpCode(
    value: OP_LESSTHAN,
    name: "OP_LESSTHAN",
    length: 1,
  ),
  OP_GREATERTHAN: OpCode(
    value: OP_GREATERTHAN,
    name: "OP_GREATERTHAN",
    length: 1,
  ),
  OP_LESSTHANOREQUAL: OpCode(
    value: OP_LESSTHANOREQUAL,
    name: "OP_LESSTHANOREQUAL",
    length: 1,
  ),
  OP_GREATERTHANOREQUAL: OpCode(
    value: OP_GREATERTHANOREQUAL,
    name: "OP_GREATERTHANOREQUAL",
    length: 1,
  ),
  OP_MIN: OpCode(
    value: OP_MIN,
    name: "OP_MIN",
    length: 1,
  ),
  OP_MAX: OpCode(
    value: OP_MAX,
    name: "OP_MAX",
    length: 1,
  ),
  OP_WITHIN: OpCode(
    value: OP_WITHIN,
    name: "OP_WITHIN",
    length: 1,
  ),

  // Crypto opcodes.
  OP_RIPEMD160: OpCode(
    value: OP_RIPEMD160,
    name: "OP_RIPEMD160",
    length: 1,
  ),
  OP_SHA1: OpCode(
    value: OP_SHA1,
    name: "OP_SHA1",
    length: 1,
  ),
  OP_SHA256: OpCode(
    value: OP_SHA256,
    name: "OP_SHA256",
    length: 1,
  ),
  OP_HASH160: OpCode(
    value: OP_HASH160,
    name: "OP_HASH160",
    length: 1,
  ),
  OP_HASH256: OpCode(
    value: OP_HASH256,
    name: "OP_HASH256",
    length: 1,
  ),
  OP_CODESEPARATOR: OpCode(
    value: OP_CODESEPARATOR,
    name: "OP_CODESEPARATOR",
    length: 1,
  ),
  OP_CHECKSIG: OpCode(
    value: OP_CHECKSIG,
    name: "OP_CHECKSIG",
    length: 1,
  ),
  OP_CHECKSIGVERIFY: OpCode(
    value: OP_CHECKSIGVERIFY,
    name: "OP_CHECKSIGVERIFY",
    length: 1,
  ),
  OP_CHECKMULTISIG: OpCode(
    value: OP_CHECKMULTISIG,
    name: "OP_CHECKMULTISIG",
    length: 1,
  ),
  OP_CHECKMULTISIGVERIFY: OpCode(
    value: OP_CHECKMULTISIGVERIFY,
    name: "OP_CHECKMULTISIGVERIFY",
    length: 1,
  ),

  // Reserved opcodes.
  OP_NOP1: OpCode(
    value: OP_NOP1,
    name: "OP_NOP1",
    length: 1,
  ),
  OP_NOP4: OpCode(
    value: OP_NOP4,
    name: "OP_NOP4",
    length: 1,
  ),
  OP_NOP5: OpCode(
    value: OP_NOP5,
    name: "OP_NOP5",
    length: 1,
  ),
  OP_NOP6: OpCode(
    value: OP_NOP6,
    name: "OP_NOP6",
    length: 1,
  ),
  OP_NOP7: OpCode(
    value: OP_NOP7,
    name: "OP_NOP7",
    length: 1,
  ),
  OP_NOP8: OpCode(
    value: OP_NOP8,
    name: "OP_NOP8",
    length: 1,
  ),
  OP_NOP9: OpCode(
    value: OP_NOP9,
    name: "OP_NOP9",
    length: 1,
  ),
  OP_NOP10: OpCode(
    value: OP_NOP10,
    name: "OP_NOP10",
    length: 1,
  ),

  // Undefined opcodes.
  OP_UNKNOWN186: OpCode(
    value: OP_UNKNOWN186,
    name: "OP_UNKNOWN186",
    length: 1,
  ),
  OP_UNKNOWN187: OpCode(
    value: OP_UNKNOWN187,
    name: "OP_UNKNOWN187",
    length: 1,
  ),
  OP_UNKNOWN188: OpCode(
    value: OP_UNKNOWN188,
    name: "OP_UNKNOWN188",
    length: 1,
  ),
  OP_UNKNOWN189: OpCode(
    value: OP_UNKNOWN189,
    name: "OP_UNKNOWN189",
    length: 1,
  ),
  OP_UNKNOWN190: OpCode(
    value: OP_UNKNOWN190,
    name: "OP_UNKNOWN190",
    length: 1,
  ),
  OP_UNKNOWN191: OpCode(
    value: OP_UNKNOWN191,
    name: "OP_UNKNOWN191",
    length: 1,
  ),
  OP_UNKNOWN192: OpCode(
    value: OP_UNKNOWN192,
    name: "OP_UNKNOWN192",
    length: 1,
  ),
  OP_UNKNOWN193: OpCode(
    value: OP_UNKNOWN193,
    name: "OP_UNKNOWN193",
    length: 1,
  ),
  OP_UNKNOWN194: OpCode(
    value: OP_UNKNOWN194,
    name: "OP_UNKNOWN194",
    length: 1,
  ),
  OP_UNKNOWN195: OpCode(
    value: OP_UNKNOWN195,
    name: "OP_UNKNOWN195",
    length: 1,
  ),
  OP_UNKNOWN196: OpCode(
    value: OP_UNKNOWN196,
    name: "OP_UNKNOWN196",
    length: 1,
  ),
  OP_UNKNOWN197: OpCode(
    value: OP_UNKNOWN197,
    name: "OP_UNKNOWN197",
    length: 1,
  ),
  OP_UNKNOWN198: OpCode(
    value: OP_UNKNOWN198,
    name: "OP_UNKNOWN198",
    length: 1,
  ),
  OP_UNKNOWN199: OpCode(
    value: OP_UNKNOWN199,
    name: "OP_UNKNOWN199",
    length: 1,
  ),
  OP_UNKNOWN200: OpCode(
    value: OP_UNKNOWN200,
    name: "OP_UNKNOWN200",
    length: 1,
  ),
  OP_UNKNOWN201: OpCode(
    value: OP_UNKNOWN201,
    name: "OP_UNKNOWN201",
    length: 1,
  ),
  OP_UNKNOWN202: OpCode(
    value: OP_UNKNOWN202,
    name: "OP_UNKNOWN202",
    length: 1,
  ),
  OP_UNKNOWN203: OpCode(
    value: OP_UNKNOWN203,
    name: "OP_UNKNOWN203",
    length: 1,
  ),
  OP_UNKNOWN204: OpCode(
    value: OP_UNKNOWN204,
    name: "OP_UNKNOWN204",
    length: 1,
  ),
  OP_UNKNOWN205: OpCode(
    value: OP_UNKNOWN205,
    name: "OP_UNKNOWN205",
    length: 1,
  ),
  OP_UNKNOWN206: OpCode(
    value: OP_UNKNOWN206,
    name: "OP_UNKNOWN206",
    length: 1,
  ),
  OP_UNKNOWN207: OpCode(
    value: OP_UNKNOWN207,
    name: "OP_UNKNOWN207",
    length: 1,
  ),
  OP_UNKNOWN208: OpCode(
    value: OP_UNKNOWN208,
    name: "OP_UNKNOWN208",
    length: 1,
  ),
  OP_UNKNOWN209: OpCode(
    value: OP_UNKNOWN209,
    name: "OP_UNKNOWN209",
    length: 1,
  ),
  OP_UNKNOWN210: OpCode(
    value: OP_UNKNOWN210,
    name: "OP_UNKNOWN210",
    length: 1,
  ),
  OP_UNKNOWN211: OpCode(
    value: OP_UNKNOWN211,
    name: "OP_UNKNOWN211",
    length: 1,
  ),
  OP_UNKNOWN212: OpCode(
    value: OP_UNKNOWN212,
    name: "OP_UNKNOWN212",
    length: 1,
  ),
  OP_UNKNOWN213: OpCode(
    value: OP_UNKNOWN213,
    name: "OP_UNKNOWN213",
    length: 1,
  ),
  OP_UNKNOWN214: OpCode(
    value: OP_UNKNOWN214,
    name: "OP_UNKNOWN214",
    length: 1,
  ),
  OP_UNKNOWN215: OpCode(
    value: OP_UNKNOWN215,
    name: "OP_UNKNOWN215",
    length: 1,
  ),
  OP_UNKNOWN216: OpCode(
    value: OP_UNKNOWN216,
    name: "OP_UNKNOWN216",
    length: 1,
  ),
  OP_UNKNOWN217: OpCode(
    value: OP_UNKNOWN217,
    name: "OP_UNKNOWN217",
    length: 1,
  ),
  OP_UNKNOWN218: OpCode(
    value: OP_UNKNOWN218,
    name: "OP_UNKNOWN218",
    length: 1,
  ),
  OP_UNKNOWN219: OpCode(
    value: OP_UNKNOWN219,
    name: "OP_UNKNOWN219",
    length: 1,
  ),
  OP_UNKNOWN220: OpCode(
    value: OP_UNKNOWN220,
    name: "OP_UNKNOWN220",
    length: 1,
  ),
  OP_UNKNOWN221: OpCode(
    value: OP_UNKNOWN221,
    name: "OP_UNKNOWN221",
    length: 1,
  ),
  OP_UNKNOWN222: OpCode(
    value: OP_UNKNOWN222,
    name: "OP_UNKNOWN222",
    length: 1,
  ),
  OP_UNKNOWN223: OpCode(
    value: OP_UNKNOWN223,
    name: "OP_UNKNOWN223",
    length: 1,
  ),
  OP_UNKNOWN224: OpCode(
    value: OP_UNKNOWN224,
    name: "OP_UNKNOWN224",
    length: 1,
  ),
  OP_UNKNOWN225: OpCode(
    value: OP_UNKNOWN225,
    name: "OP_UNKNOWN225",
    length: 1,
  ),
  OP_UNKNOWN226: OpCode(
    value: OP_UNKNOWN226,
    name: "OP_UNKNOWN226",
    length: 1,
  ),
  OP_UNKNOWN227: OpCode(
    value: OP_UNKNOWN227,
    name: "OP_UNKNOWN227",
    length: 1,
  ),
  OP_UNKNOWN228: OpCode(
    value: OP_UNKNOWN228,
    name: "OP_UNKNOWN228",
    length: 1,
  ),
  OP_UNKNOWN229: OpCode(
    value: OP_UNKNOWN229,
    name: "OP_UNKNOWN229",
    length: 1,
  ),
  OP_UNKNOWN230: OpCode(
    value: OP_UNKNOWN230,
    name: "OP_UNKNOWN230",
    length: 1,
  ),
  OP_UNKNOWN231: OpCode(
    value: OP_UNKNOWN231,
    name: "OP_UNKNOWN231",
    length: 1,
  ),
  OP_UNKNOWN232: OpCode(
    value: OP_UNKNOWN232,
    name: "OP_UNKNOWN232",
    length: 1,
  ),
  OP_UNKNOWN233: OpCode(
    value: OP_UNKNOWN233,
    name: "OP_UNKNOWN233",
    length: 1,
  ),
  OP_UNKNOWN234: OpCode(
    value: OP_UNKNOWN234,
    name: "OP_UNKNOWN234",
    length: 1,
  ),
  OP_UNKNOWN235: OpCode(
    value: OP_UNKNOWN235,
    name: "OP_UNKNOWN235",
    length: 1,
  ),
  OP_UNKNOWN236: OpCode(
    value: OP_UNKNOWN236,
    name: "OP_UNKNOWN236",
    length: 1,
  ),
  OP_UNKNOWN237: OpCode(
    value: OP_UNKNOWN237,
    name: "OP_UNKNOWN237",
    length: 1,
  ),
  OP_UNKNOWN238: OpCode(
    value: OP_UNKNOWN238,
    name: "OP_UNKNOWN238",
    length: 1,
  ),
  OP_UNKNOWN239: OpCode(
    value: OP_UNKNOWN239,
    name: "OP_UNKNOWN239",
    length: 1,
  ),
  OP_UNKNOWN240: OpCode(
    value: OP_UNKNOWN240,
    name: "OP_UNKNOWN240",
    length: 1,
  ),
  OP_UNKNOWN241: OpCode(
    value: OP_UNKNOWN241,
    name: "OP_UNKNOWN241",
    length: 1,
  ),
  OP_UNKNOWN242: OpCode(
    value: OP_UNKNOWN242,
    name: "OP_UNKNOWN242",
    length: 1,
  ),
  OP_UNKNOWN243: OpCode(
    value: OP_UNKNOWN243,
    name: "OP_UNKNOWN243",
    length: 1,
  ),
  OP_UNKNOWN244: OpCode(
    value: OP_UNKNOWN244,
    name: "OP_UNKNOWN244",
    length: 1,
  ),
  OP_UNKNOWN245: OpCode(
    value: OP_UNKNOWN245,
    name: "OP_UNKNOWN245",
    length: 1,
  ),
  OP_UNKNOWN246: OpCode(
    value: OP_UNKNOWN246,
    name: "OP_UNKNOWN246",
    length: 1,
  ),
  OP_UNKNOWN247: OpCode(
    value: OP_UNKNOWN247,
    name: "OP_UNKNOWN247",
    length: 1,
  ),
  OP_UNKNOWN248: OpCode(
    value: OP_UNKNOWN248,
    name: "OP_UNKNOWN248",
    length: 1,
  ),
  OP_UNKNOWN249: OpCode(
    value: OP_UNKNOWN249,
    name: "OP_UNKNOWN249",
    length: 1,
  ),

  // bitcoins Core internal use opcode.  Defined here for completeness.
  OP_SMALLINTEGER: OpCode(
    value: OP_SMALLINTEGER,
    name: "OP_SMALLINTEGER",
    length: 1,
  ),
  OP_PUBKEYS: OpCode(
    value: OP_PUBKEYS,
    name: "OP_PUBKEYS",
    length: 1,
  ),
  OP_UNKNOWN252: OpCode(
    value: OP_UNKNOWN252,
    name: "OP_UNKNOWN252",
    length: 1,
  ),
  OP_PUBKEYHASH: OpCode(
    value: OP_PUBKEYHASH,
    name: "OP_PUBKEYHASH",
    length: 1,
  ),
  OP_PUBKEY: OpCode(
    value: OP_PUBKEY,
    name: "OP_PUBKEY",
    length: 1,
  ),

  OP_INVALIDOPCODE: OpCode(
    value: OP_INVALIDOPCODE,
    name: "OP_INVALIDOPCODE",
    length: 1,
  ),
};

Map<String, String> opcodeOnelineRepls = {
  "OP_1NEGATE": "-1",
  "OP_0": "0",
  "OP_1": "1",
  "OP_2": "2",
  "OP_3": "3",
  "OP_4": "4",
  "OP_5": "5",
  "OP_6": "6",
  "OP_7": "7",
  "OP_8": "8",
  "OP_9": "9",
  "OP_10": "10",
  "OP_11": "11",
  "OP_12": "12",
  "OP_13": "13",
  "OP_14": "14",
  "OP_15": "15",
  "OP_16": "16"
};
