import 'package:solana/solana.dart';
import 'package:solana/src/common/byte_array.dart';
import 'package:solana/src/encoder/constants.dart';

class SerumInstruction extends Instruction {
  /// Create a system program instruction with [data], for [accounts].
  ///
  /// Since [accounts] is interpreted by the specific program that will
  /// be called, then it's the responsibility of the caller to pass the
  /// array correctly sorted, e.g., for a transfer program the `source` should
  /// be before the `destination`
  const SerumInstruction({
    required List<AccountMeta> accounts,
    required ByteArray data,
    required String programId,
  }) : super(
          programId: programId,
          accounts: accounts,
          data: data,
        );

  factory SerumInstruction.newOrder({
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
  }) {
    final keys = [
      AccountMeta.writeable(pubKey: market, isSigner: false),
      AccountMeta.writeable(pubKey: openOrders, isSigner: false),
      AccountMeta.writeable(pubKey: requestQueue, isSigner: false),
      AccountMeta.writeable(pubKey: eventQueue, isSigner: false),
      AccountMeta.writeable(pubKey: bids, isSigner: false),
      AccountMeta.writeable(pubKey: asks, isSigner: false),
      AccountMeta.writeable(pubKey: payer, isSigner: false),
      AccountMeta.readonly(pubKey: owner, isSigner: true),
      AccountMeta.writeable(pubKey: baseVault, isSigner: false),
      AccountMeta.writeable(pubKey: quoteVault, isSigner: false),
      AccountMeta.readonly(pubKey: TokenProgram.programId, isSigner: false),
      AccountMeta.readonly(pubKey: Sysvar.rent, isSigner: false),
    ];
    if (feeDiscountPubkey != null) {
      keys.add(AccountMeta(pubKey: feeDiscountPubkey, isSigner: false, isWriteable: false));
    }

    final encodeSide = side == 'buy' ? Buffer.fromUint32(0) : Buffer.fromUint32(1);

    final encodeOrderType = orderType == 'limit'
        ? Buffer.fromUint32(0)
        : orderType == 'ioc'
            ? Buffer.fromUint32(1)
            : Buffer.fromUint32(2);

    final bufferList = clientId != null
        ? [
            Buffer.fromUint8(0),
            Buffer.fromUint32(10),
            encodeSide,
            Buffer.fromUint64(limitPrice),
            Buffer.fromUint64(maxBaseQuantity),
            Buffer.fromUint64(maxQuoteQuantity),
            Buffer.fromUint32(0),
            encodeOrderType,
            Buffer.fromUint64(clientId),
            Buffer.fromUint8(255),
            Buffer.fromUint8(255),
          ]
        : [
            // [0],
            // Version (fixed)
            Buffer.fromUint8(0),
            // [10, 0, 0, 0],
            // NewOrder (fixed)
            Buffer.fromUint32(10),
            // [1, 0, 0, 0],
            // Buy : 0 , Sell : 1
            // Buffer.fromUint32(1),
            encodeSide,
            // [16, 27, 0, 0, 0, 0, 0, 0],
            // LimitPrice
            Buffer.fromUint64(limitPrice),
            // [100, 0, 0, 0, 0, 0, 0, 0],
            // maxBaseQuantity
            Buffer.fromUint64(maxBaseQuantity),
            // [64, 66, 15, 0, 0, 0, 0, 0],
            // maxQuoteQuantity
            Buffer.fromUint64(maxQuoteQuantity),
            // [0, 0, 0, 0],
            // selfTradeBehavior (decrementTake : fixed in NewOrder )
            Buffer.fromUint32(0),
            // [0, 0, 0, 0],
            // orderType
            // Buffer.fromUint32(0),
            encodeOrderType,
            // [0, 0, 0, 0, 0, 0, 0, 0],
            // clientId
            Buffer.fromUint64(0),
            // [255, 255],
            // Limit (65535 : fixed)
            Buffer.fromUint8(255),
            Buffer.fromUint8(255),
          ];

    final bufferfromByteArrays = Buffer.fromConcatenatedByteArrays([...bufferList]);

    return SerumInstruction(
      accounts: keys,
      data: bufferfromByteArrays,
      programId: programId,
    );
  }

  factory SerumInstruction.matchOrders({
    required String market,
    required String requestQueue,
    required String eventQueue,
    required String bids,
    required String asks,
    required String baseVault,
    required String quoteVault,
    int limit = 5,
    required String programId,
  }) {
    final keys = [
      AccountMeta.writeable(pubKey: market, isSigner: false),
      AccountMeta.writeable(pubKey: requestQueue, isSigner: false),
      AccountMeta.writeable(pubKey: eventQueue, isSigner: false),
      AccountMeta.writeable(pubKey: bids, isSigner: false),
      AccountMeta.writeable(pubKey: asks, isSigner: false),
      AccountMeta.writeable(pubKey: baseVault, isSigner: false),
      AccountMeta.writeable(pubKey: quoteVault, isSigner: false),
    ];

    final bufferfromByteArrays = Buffer.fromConcatenatedByteArrays([
      // version
      Buffer.fromUint8(0),
      // matchOrders number
      Buffer.fromUint32(2),
      // limit
      Buffer.fromUint8(limit),
      Buffer.fromUint8(0),
      //
    ]);
    return SerumInstruction(
      accounts: keys,
      data: bufferfromByteArrays,
      programId: programId,
    );
  }

  factory SerumInstruction.cancelOrderV2({
    required String market,
    required String bids,
    required String asks,
    required String eventQueue,
    required String openOrders,
    required String owner,
    required String side,
    required String orderId,
    required String programId,
  }) {
    final keys = [
      AccountMeta.writeable(pubKey: market, isSigner: false),
      AccountMeta.writeable(pubKey: bids, isSigner: false),
      AccountMeta.writeable(pubKey: asks, isSigner: false),
      AccountMeta.writeable(pubKey: openOrders, isSigner: false),
      AccountMeta.readonly(pubKey: owner, isSigner: true),
      AccountMeta.writeable(pubKey: eventQueue, isSigner: false),
    ];
    final encodeSide = side == 'buy' ? Buffer.fromUint32(0) : Buffer.fromUint32(1);

    final bufferfromByteArrays = Buffer.fromConcatenatedByteArrays([
      // version
      Buffer.fromUint8(0),
      // matchOrders number
      Buffer.fromUint32(2),
      // side
      encodeSide,
      Buffer.fromString(orderId),
      // Buffer.fromUint8(limit),
      //
    ]);

    return SerumInstruction(
      accounts: keys,
      data: bufferfromByteArrays,
      programId: programId,
    );
  }

  factory SerumInstruction.settleFunds({
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
  }) {
    final keys = [
      AccountMeta.writeable(pubKey: market, isSigner: false),
      AccountMeta.writeable(pubKey: openOrders, isSigner: false),
      AccountMeta.readonly(pubKey: owner, isSigner: true),
      AccountMeta.writeable(pubKey: baseVault, isSigner: false),
      AccountMeta.writeable(pubKey: quoteVault, isSigner: false),
      AccountMeta.writeable(pubKey: baseWallet, isSigner: false),
      AccountMeta.writeable(pubKey: quoteWallet, isSigner: false),
      AccountMeta.readonly(pubKey: vaultSigner, isSigner: false),
      AccountMeta.readonly(pubKey: TokenProgram.programId, isSigner: false),
    ];

    if (referrerQuoteWallet != null) {
      keys.add(AccountMeta.writeable(pubKey: referrerQuoteWallet, isSigner: false));
    }

    return SerumInstruction(
      accounts: keys,
      data: [],
      programId: programId,
    );
  }
}
