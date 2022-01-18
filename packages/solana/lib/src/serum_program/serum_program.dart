import 'package:solana/src/encoder/instruction.dart';
import 'package:solana/src/encoder/message.dart';
import 'package:solana/src/serum_program/serum_instruction.dart';

class SerumProgram extends Message {
  const SerumProgram._({
    required List<Instruction> instructions,
  }) : super(instructions: instructions);

  /// Create Order
  ///
  /// if [openOrders] is not exited, should create new account
  /// [side] = buy : 0 , sell : 1
  ///
  /// [orderType] = limit : 0 , ioc : 1 , postOnly = 2
  ///
  /// [limitPrice], [maxBaseQuantity], [maxQuoteQuantity] must need transformation
  ///

  factory SerumProgram.newOrder({
    required String market,
    required String openOrders,
    required String payer,
    required String owner,
    required String requestQueue,
    required String eventQueue,
    required String bids,
    required String asks,
    required String baseVault,
    required String quoteVault,
    required String side,
    required int limitPrice,
    required int maxBaseQuantity,
    required int maxQuoteQuantity,
    required String programId,
    required String orderType,
    int? clientId,
    String? feeDiscountPubkey,
  }) =>
      SerumProgram._(instructions: [
        SerumInstruction.newOrder(
          market: market,
          openOrders: openOrders,
          payer: payer,
          owner: owner,
          requestQueue: requestQueue,
          eventQueue: eventQueue,
          bids: bids,
          asks: asks,
          baseVault: baseVault,
          quoteVault: quoteVault,
          side: side,
          limitPrice: limitPrice,
          maxBaseQuantity: maxBaseQuantity,
          maxQuoteQuantity: maxQuoteQuantity,
          programId: programId,
          orderType: orderType,
          clientId: clientId,
          feeDiscountPubkey: feeDiscountPubkey,
        )
      ]);

  factory SerumProgram.matchOrders({
    required String market,
    required String requestQueue,
    required String eventQueue,
    required String bids,
    required String asks,
    required String baseVault,
    required String quoteVault,
    required String programId,
  }) =>
      SerumProgram._(instructions: [
        SerumInstruction.matchOrders(
          market: market,
          requestQueue: requestQueue,
          eventQueue: eventQueue,
          bids: bids,
          asks: asks,
          baseVault: baseVault,
          quoteVault: quoteVault,
          programId: programId,
        )
      ]);

  factory SerumProgram.cancelOrderV2({
    required String market,
    required String bids,
    required String asks,
    required String eventQueue,
    required String openOrders,
    required String owner,
    required String side,
    required String orderId,
    required String programId,
  }) =>
      SerumProgram._(instructions: [
        SerumInstruction.cancelOrderV2(
          market: market,
          bids: bids,
          asks: asks,
          eventQueue: eventQueue,
          openOrders: openOrders,
          owner: owner,
          side: side,
          orderId: orderId,
          programId: programId,
        ),
      ]);

  factory SerumProgram.settleFunds({
    required String market,
    required String openOrders,
    required String owner,
    required String baseVault,
    required String quoteVault,
    required String baseWallet,
    required String quoteWallet,
    required String vaultSigner,
    required String programId,
    String? referrerQuoteWallet,
  }) =>
      SerumProgram._(instructions: [
        SerumInstruction.settleFunds(
          market: market,
          openOrders: openOrders,
          owner: owner,
          baseVault: baseVault,
          quoteVault: quoteVault,
          baseWallet: baseWallet,
          quoteWallet: quoteWallet,
          vaultSigner: vaultSigner,
          programId: programId,
          referrerQuoteWallet: referrerQuoteWallet,
        ),
      ]);
}
