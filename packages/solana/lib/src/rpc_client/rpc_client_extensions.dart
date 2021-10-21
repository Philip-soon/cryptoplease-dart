part of 'rpc_client.dart';

/// These methods are not part of the RPC api so we are including them as
/// an extension instead.
extension Convenience on RPCClient {
  /// Convenience method to sign a transaction with [message] using [signers].
  /// Send the transaction after signing it.
  ///
  /// The first element of the [signers] array is considered to be the
  /// fee payer.
  ///
  /// For [commitment] parameter description [see this document][see this document]
  /// [Commitment.processed] is not supported as [commitment].
  ///
  /// [see this document]: https://docs.solana.com/developing/clients/jsonrpc-api#configuring-state-commitment
  Future<TransactionSignature> signAndSendTransaction(
    Message message,
    List<Ed25519HDKeyPair> signers,
  ) async {
    final recentBlockhash = await getRecentBlockhash();
    final signedTx = await signTransaction(recentBlockhash, message, signers);

    return sendTransaction(signedTx.encode());
  }

  /// This is just a helper function that allows the caller
  /// to wait for the transaction with signature [signature] to
  /// be in a desired [desiredStatus].
  ///
  /// Optionally a [timeout] can be specified and given that the state
  /// did not change to or past [desiredStatus] the method will
  /// throw an error.
  ///
  /// Note: the default [timeout] is 30 seconds.
  Future<void> waitForSignatureStatus(
    TransactionSignature signature,
    TxStatus desiredStatus,
  ) async {
    // Simply, if the returned result did not error out it means the desiredStatus
    // was fulfilled
    final optionalError = await _subscriptionClient
        .signatureSubscribe(signature, status: desiredStatus)
        .first;
    final error = optionalError.err;
    if (error != null) {
      throw Exception(error.toString());
    }
  }

  /// Get the [limit] most recent transactions for the [address] account
  ///
  /// For [commitment] parameter description [see this document][see this document]
  /// [Commitment.processed] is not supported as [commitment].
  ///
  /// [see this document]: https://docs.solana.com/developing/clients/jsonrpc-api#configuring-state-commitment
  Future<Iterable<TransactionResponse>> getTransactionsList(
    String address, {
    int limit = 10,
    Commitment? commitment,
  }) async {
    // FIXME: this must be replaced soon
    // ignore: deprecated_member_use_from_same_package
    final signatures = await getConfirmedSignaturesForAddress2(
      address,
      limit: limit,
      commitment: commitment,
    );
    final transactions = await Future.wait(
      signatures.map(
        (s) => getConfirmedTransaction(s.signature, commitment: commitment),
      ),
    );

    // We are sure that no transaction in this list is `null` because
    // we have queried the signatures so they surely exist
    return transactions.whereType();
  }
}
