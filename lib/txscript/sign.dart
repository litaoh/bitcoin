part of bitcoins.txscript;

///Padding
List<int> _rmPadding(List<int> buf) {
  var i = 0;
  var len = buf.length - 1;
  while (buf[i] == 0 && (buf[i + 1] & 0x80) == 0 && i < len) {
    i++;
  }
  if (i == 0) {
    return buf;
  }
  return buf.sublist(i);
}

/// constructLength
void _constructLength(List<int> arr, int len) {
  if (len < 0x80) {
    arr.add(len);
    return;
  }
  var octets = 1 + (math.log(len) ~/ math.log(2) >> 3);
  arr.add(octets | 0x80);
  while (--octets > 0) {
    arr.add((len >> (octets << 3)) & 0xff);
  }
  arr.add(len);
}

/// sigToList
List<int> _sigToList(List<int> r, List<int> s) {
  // Pad values
  if (r[0] & 0x80 != 0) {
    r.insert(0, 0);
  }
  // Pad values
  if (s[0] & 0x80 != 0) {
    s.insert(0, 0);
  }

  r = _rmPadding(r);
  s = _rmPadding(s);

  while (s[0] == 0 && (s[1] & 0x80) == 0) {
    s = s.sublist(1);
  }
  var arr = <int>[0x02];
  _constructLength(arr, r.length);
  arr.addAll(r);
  arr.add(0x02);
  _constructLength(arr, s.length);
  arr.addAll(s);
  var res = <int>[0x30];
  _constructLength(res, arr.length);
  res.addAll(arr);
  return res;
}

/// ECSign
pointycastle.ECSignature ECSign(pointycastle.ECPrivateKey key, Uint8List hash) {
  var signer = ECDSASigner(null, HMac(SHA256Digest(), 64));
  var pkp = PrivateKeyParameter(key);
  signer.init(true, pkp);
  pointycastle.ECSignature sig = signer.generateSignature(hash);
  var nh = (hdkeychain.ecc.n >> 1);
  var s = sig.s;
  if (sig.s.compareTo(nh) > 0) {
    s = hdkeychain.ecc.n - sig.s;
  }

  return pointycastle.ECSignature(sig.r, s);
}

/// raw TxIn witness signature
Uint8List rawTxInWitnessSignature(
    transaction.MsgTx tx,
    TxSigHashes sigHashes,
    int idx,
    utils.Amount amt,
    Uint8List subScript,
    int hashType,
    pointycastle.PrivateKey key) {
  var parsedScript = parseScript(subScript);

  var hash =
      calcWitnessSignatureHash(parsedScript, sigHashes, hashType, tx, idx, amt);
  var sig = ECSign(key, hash);

  var ret = _sigToList(
      utils.intToBytes(sig.r).toList(), utils.intToBytes(sig.s).toList());
  ret.add(hashType);
  return Uint8List.fromList(ret);
}

/// raw TxIn signature
Uint8List rawTxInSignature(transaction.MsgTx tx, int idx, Uint8List subScript,
    int hashType, pointycastle.ECPrivateKey key) {
  List<ParsedOpcode> parsedScript;
  try {
    parsedScript = parseScript(subScript);
  } catch (_) {}

  var hash = calcSignatureHash(parsedScript, hashType, tx, idx);

  var sig = ECSign(key, hash);
  var ret = _sigToList(
      utils.intToBytes(sig.r).toList(), utils.intToBytes(sig.s).toList());
  ret.add(hashType);
  return Uint8List.fromList(ret);
}

/// signature script
Uint8List signatureScript(transaction.MsgTx tx, int idx, Uint8List subScript,
    int hashType, pointycastle.ECPrivateKey privKey, bool compress) {
  var sig = rawTxInSignature(tx, idx, subScript, hashType, privKey);

  var pkScript = (hdkeychain.ecc.G * privKey.d).getEncoded(compress);
  return ScriptBuilder().addData(sig).addData(pkScript).script();
}

/// witness signature
List<Uint8List> witnessSignature(
    transaction.MsgTx tx,
    TxSigHashes sigHashes,
    int idx,
    utils.Amount amt,
    Uint8List subscript,
    int hashType,
    pointycastle.ECPrivateKey privKey,
    bool compress) {
  var sig = rawTxInWitnessSignature(
      tx, sigHashes, idx, amt, subscript, hashType, privKey);

  var pk = privKey.parameters.G * privKey.d;

  var pkData = pk.getEncoded(compress);

  return [sig, pkData];
}

/// sign
List<dynamic> sign(chaincfg.Params net, transaction.MsgTx tx, int idx,
    Uint8List subScript, int hashType, KeyClosure kdb, ScriptClosure sdb) {
  var data = extractPkScriptAddrs(subScript, net);
  int cls = data[0];
  List<utils.Address> addrs = data[1];
  int nRequired = data[2];
  switch (cls) {
    case PUB_KEY_HASH_TY:
      var resp = kdb.getKey(addrs[0]);
      var script = signatureScript(
          tx, idx, subScript, hashType, resp.key, resp.compressed);

      return <dynamic>[script, cls, addrs, nRequired];
    case SCRIPT_HASH_TY:
      var script = sdb.getScript(addrs[0]);
      return <dynamic>[script, cls, addrs, nRequired];
    case NULL_DATA_TY:
      throw FormatException("can't sign NULLDATA transactions");
      break;
    default:
      throw FormatException("can't sign unknown transactions");
  }
}

/// merge scripts
Uint8List mergeScripts(
    chaincfg.Params net,
    transaction.MsgTx tx,
    int idx,
    Uint8List pkScript,
    int cls,
    List<utils.Address> addrs,
    int nRequired,
    Uint8List sigScript,
    Uint8List prevScript) {
  switch (cls) {
    case SCRIPT_HASH_TY:
      List<ParsedOpcode> sigPops;
      try {
        sigPops = parseScript(sigScript);
      } catch (_) {}
      if (sigPops?.isEmpty ?? true) {
        return prevScript;
      }
      List<ParsedOpcode> prevPops;
      try {
        prevPops = parseScript(prevScript);
      } catch (_) {}
      if (prevPops?.isEmpty ?? true) {
        return sigScript;
      }

      var script = sigPops[sigPops.length - 1].data;

      var data = extractPkScriptAddrs(script, net);
      int cls = data[0];
      List<utils.Address> addrs = data[1];
      nRequired = data[2];

      try {
        sigScript = unparseScript(sigPops);
      } catch (_) {}
      try {
        prevScript = unparseScript(prevPops);
      } catch (_) {}

      var mergedScript = mergeScripts(
          net, tx, idx, script, cls, addrs, nRequired, sigScript, prevScript);

      return ScriptBuilder().addOps(mergedScript).addData(script).script();
    default:
      if (sigScript.length > prevScript.length) {
        return sigScript;
      }
      return prevScript;
  }
}

/// sign Tx Output
Uint8List signTxOutput(
    chaincfg.Params net,
    transaction.MsgTx tx,
    int idx,
    Uint8List pkScript,
    int hashType,
    KeyClosure kdb,
    ScriptClosure sdb,
    Uint8List previousScript) {
  var data = sign(net, tx, idx, pkScript, hashType, kdb, sdb);
  Uint8List sigScript = data[0];
  int cls = data[1];
  List<utils.Address> addrs = data[2];
  int nRequired = data[3];

  if (cls == SCRIPT_HASH_TY) {
    data = sign(net, tx, idx, sigScript, hashType, kdb, sdb);
    Uint8List realSigScript = data[0];

    var builder = ScriptBuilder();
    builder.addOps(realSigScript).addData(sigScript);
    sigScript = builder.script();
  }

  var mergedScript = mergeScripts(
      net, tx, idx, pkScript, cls, addrs, nRequired, sigScript, previousScript);

  return mergedScript;
}
