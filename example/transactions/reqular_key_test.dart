// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:xrp_dart/src/crypto/keypair/xrpl_private_key.dart';
import 'package:xrp_dart/src/formating/bytes_num_formating.dart';
import 'package:xrp_dart/src/xrpl/helper.dart';
import 'package:xrp_dart/src/xrpl/models/currencies/currencies.dart';
import 'package:xrp_dart/src/xrpl/models/memo.dart';
import 'package:xrp_dart/src/xrpl/models/payment.dart';
import 'package:xrp_dart/src/xrpl/models/account/set_reqular_key.dart';

import '../main.dart';

void reqularKeyTest() async {
  final reqularWallet =
      XRPPrivateKey.fromEntropy("35039337a49e2ee0ee507544e62a0bb2");
  final masterWallet =
      XRPPrivateKey.fromEntropy("f7f9ff93d716eaced222a3c52a3b2a36");
  final destinationWallet =
      XRPPrivateKey.fromEntropy("396c8a5c6e088518b469822923b17039");
  await setupOrUpdateReqularKey(
      masterWallet, reqularWallet.getPublic().toAddress().address);
  await sendTransactionUsingReqularKey(
      destinationWallet.getPublic().toAddress().address,
      masterWallet.getPublic().toAddress().address,
      reqularWallet,
      CurrencyAmount.xrp(BigInt.from(1000000)));
}

Future<void> setupOrUpdateReqularKey(
    XRPPrivateKey owner, String reqularWalletAddress) async {
  final String ownerAddress = owner.getPublic().toAddress().address;
  final String ownerPublic = owner.getPublic().toHex();

  String memoData = bytesToHex(utf8.encode("MRTNETWORK.com"));
  String memoType = bytesToHex(utf8.encode("Text"));
  String mempFormat = bytesToHex(utf8.encode("text/plain"));
  final memo =
      XRPLMemo(memoData: memoData, memoFormat: mempFormat, memoType: memoType);
  print("owner public: $ownerPublic");
  final transaction = SetRegularKey(
      account: ownerAddress,
      signingPubKey: ownerPublic,
      regularKey: reqularWalletAddress,
      memos: [memo]);
  print("autfil trnsction");
  await autoFill(rpc, transaction);
  final blob = transaction.toBlob();
  print("sign transction");
  final sig = owner.sign(blob);
  print("Set transaction signature");
  transaction.setSignature(sig);
  final trhash = transaction.getHash();
  print("transaction hash: $trhash");

  final trBlob = transaction.toBlob(forSigning: false);
  print("regenarate transaction blob");

  final result = await rpc.submit(trBlob);
  print("transaction hash: ${result.txJson.hash}");
  print("engine result: ${result.engineResult}");
  print("engine result message: ${result.engineResultMessage}");
  print("is success: ${result.isSuccess}");
}

Future<void> sendTransactionUsingReqularKey(
    String destination,
    String masterWalletAddress,
    XRPPrivateKey reqularWallet,
    CurrencyAmount amount) async {
  final String signerPublic = reqularWallet.getPublic().toHex();

  String memoData = bytesToHex(utf8.encode("MRTNETWORK.com"));
  String memoType = bytesToHex(utf8.encode("Text"));
  String mempFormat = bytesToHex(utf8.encode("text/plain"));
  final memo =
      XRPLMemo(memoData: memoData, memoFormat: mempFormat, memoType: memoType);
  final transaction = Payment(
      destination: destination,
      account: masterWalletAddress,
      memos: [memo],
      amount: amount,
      signingPubKey: signerPublic);
  print("autfil trnsction");
  await autoFill(rpc, transaction);
  final blob = transaction.toBlob();
  print("sign transction with reqular wallet");
  final sig = reqularWallet.sign(blob);
  print("Set transaction signature");
  transaction.setSignature(sig);
  final trhash = transaction.getHash();
  print("transaction hash: $trhash");

  final trBlob = transaction.toBlob(forSigning: false);
  print("regenarate transaction blob");

  final result = await rpc.submit(trBlob);
  print("transaction hash: ${result.txJson.hash}");
  print("engine result: ${result.engineResult}");
  print("engine result message: ${result.engineResultMessage}");
  print("is success: ${result.isSuccess}");
}