module IxoDid
  class InvalidDidDoc < StandardError; end

  def self.store(user, diddoc)
    raise InvalidDidDoc unless valid_diddoc?(diddoc)

    Ixo.create!(
      user_id: user.id,
      diddoc: diddoc,
      nonce: generate_nonce,
    )
  end

  def self.valid_diddoc?(diddoc)
    diddoc.fetch("did") == "did:sov:" + Base58.binary_to_base58(
      Base58.base58_to_binary(
        diddoc.fetch("pubKey"),
        :bitcoin,
      )[0...16],
      :bitcoin,
      true,
    )
  rescue KeyError
    false
  rescue ArgumentError # Base58
    false
  end

  def self.verify_nonce_signature(ixo, signature_hexed)
    verify_key = ixo[:diddoc].fetch("pubKey")
    verify_key_bytes = Base58.base58_to_binary(verify_key, :bitcoin)
    verify_key = Ed25519::VerifyKey.new(verify_key_bytes)
    signature_bytes = Hex.decode(signature_hexed)

    begin
      verify_key.verify(signature_bytes, ixo[:nonce])
      true
    rescue ArgumentError # Ed25519
      false
    end
  rescue Hex::EncodingError
    false
  rescue Ed25519::VerifyError
    false
  end

  def self.generate_nonce(prefix: "fractal")
    "#{prefix}:sign:#{SecureRandom.uuid}"
  end

  def self.send_ixo_claim_to_ixo(ixo_claim)
    IxoNotifier.new.enqueue_claim(ixo_claim)
  end

  def self.ledger(diddoc, signature)
    did_claim = IxoCredential.new.transaction(10, diddoc, signature)

    IxoAPI.broadcast(did_claim.to_json)
  end
end
