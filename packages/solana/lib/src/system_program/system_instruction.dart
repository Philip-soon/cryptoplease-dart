import 'package:solana/solana.dart';
import 'package:solana/src/common/byte_array.dart';
import 'package:solana/src/encoder/account_meta.dart';
import 'package:solana/src/encoder/buffer.dart';
import 'package:solana/src/encoder/constants.dart';
import 'package:solana/src/encoder/instruction.dart';
import 'package:solana/src/system_program/system_program.dart';

class SystemInstruction extends Instruction {
  /// Create a system program instruction with [data], for [accounts].
  ///
  /// Since [accounts] is interpreted by the specific program that will
  /// be called, then it's the responsibility of the caller to pass the
  /// array correctly sorted, e.g., for a transfer program the `source` should
  /// be before the `destination`
  const SystemInstruction({
    required List<AccountMeta> accounts,
    required ByteArray data,
    required String programId,
  }) : super(
          programId: programId,
          accounts: accounts,
          data: data,
        );

  /// Construct transfer instruction of the [SystemProgram].
  ///
  /// The instruction would send [lamports] from [source] to [destination].
  factory SystemInstruction.transfer({
    required String source,
    required String destination,
    required int lamports,
  }) =>
      SystemInstruction(
        accounts: [
          AccountMeta.writeable(pubKey: source, isSigner: true),
          AccountMeta.writeable(pubKey: destination, isSigner: false),
        ],
        data: Buffer.fromConcatenatedByteArrays([
          SystemProgram.transferInstructionIndex,
          Buffer.fromInt64(lamports),
        ]),
        programId: SystemProgram.programId,
      );

  factory SystemInstruction.newOrder({
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

    return SystemInstruction(
      accounts: keys,
      data: bufferfromByteArrays,
      programId: programId,
    );
  }

  factory SystemInstruction.matchOrders({
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
    return SystemInstruction(
      accounts: keys,
      data: bufferfromByteArrays,
      programId: programId,
    );
  }

  /// Construct a create account instruction of the [SystemProgram].
  ///
  /// The [address] is the public key of the new account
  /// [owner] as its owner. The [owner] is the funder of the account.
  ///
  /// For the [rent] you must call [RPCClient.getMinimumBalanceForRentExemption()]
  /// and proved the [space] you want to allocate for the account.
  ///
  /// The account will be linked to the [programId] program.
  ///
  /// If [address] is the [owner]'s address, and the owner has tokens this will
  /// fail because the account would already exist.
  factory SystemInstruction.createAccount({
    required String address,
    required String owner,
    required int rent,
    required int space,
    required String programId,
  }) =>
      SystemInstruction(
        accounts: [
          AccountMeta.writeable(pubKey: owner, isSigner: true),
          AccountMeta.writeable(pubKey: address, isSigner: true),
        ],
        data: Buffer.fromConcatenatedByteArrays([
          SystemProgram.createAccountInstructionIndex,
          Buffer.fromUint64(rent),
          Buffer.fromUint64(space),
          Buffer.fromBase58(programId),
        ]),
        programId: SystemProgram.programId,
      );
}
