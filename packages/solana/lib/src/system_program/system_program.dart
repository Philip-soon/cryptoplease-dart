import 'package:solana/src/encoder/instruction.dart';
import 'package:solana/src/encoder/message.dart';
import 'package:solana/src/system_program/system_instruction.dart';

export 'package:solana/src/system_program/system_instruction.dart';

class SystemProgram extends Message {
  const SystemProgram._({
    required List<Instruction> instructions,
  }) : super(instructions: instructions);

  /// Construct a transfer message to send [lamports] SOL tokens from [source]
  /// to [destination].
  factory SystemProgram.transfer({
    required String source,
    required String destination,
    required int lamports,
  }) =>
      SystemProgram._(
        instructions: [
          SystemInstruction.transfer(
            source: source,
            destination: destination,
            lamports: lamports,
          )
        ],
      );


  factory SystemProgram.newOrder({
    required String market,
    required String openOrders,
    required String payer,
    required String owner,
    required String requestQueue,
    required String baseVault,
    required String quoteVault,
    required String side,
    required int limitPrice,
    required int maxQuantity,
    required String programId,
    required String orderType,
    String? clientId,
    String? feeDiscountPubkey,
  }) =>
      SystemProgram._(instructions: [
        SystemInstruction.newOrder(
          market: market,
          openOrders: openOrders,
          payer: payer,
          owner: owner,
          requestQueue: requestQueue,
          baseVault: baseVault,
          quoteVault: quoteVault,
          side: side,
          limitPrice: limitPrice,
          maxQuantity: maxQuantity,
          programId: programId,
          orderType: orderType,
          clientId: clientId,
          feeDiscountPubkey: feeDiscountPubkey,
        )
      ]);

  /// Construct a create account message.
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
  factory SystemProgram.createAccount({
    required String address,
    required String owner,
    required int rent,
    required int space,
    required String programId,
  }) =>
      SystemProgram._(instructions: [
        SystemInstruction.createAccount(
          address: address,
          owner: owner,
          rent: rent,
          space: space,
          programId: programId,
        ),
      ]);

  static const programId = '11111111111111111111111111111111';
  static const createAccountInstructionIndex = [0, 0, 0, 0];
  static const transferInstructionIndex = [2, 0, 0, 0];
}
