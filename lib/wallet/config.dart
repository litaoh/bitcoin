part of bitcoin.wallet;

class Config {
  chaincfg.Params net;

  int gapLimit;
  bool addressReuse;
  bool multipleAddress;
  AccountStorage accountStorage;
  Config(
      {this.net,
      this.gapLimit,
      this.addressReuse,
      this.multipleAddress,
      this.accountStorage});
}
