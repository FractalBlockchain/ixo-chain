class IxoCredential
  def initialize
    @identity = SovrinIdentity.new(Hex.decode(ENV["IXO_DID_PRIVATE_KEY"]))
  end

  def sign(payload)
    Hex.encode(@identity.sign(payload))
  end

  def kyc(user_did)
    issue_timestamp = Time.now.utc.iso8601(3)

    payload = {
      credential: {
        type: %w[Credential ProofOfKYC],
        issuer: @identity.did,
        issued: issue_timestamp,
        claim: {
          id: user_did,
          KYCValidated: true,
        },
      },
    }

    transaction(24, payload, sign(payload.to_json))
  end

  def ledger
    payload = {
      didDoc: {
        did: @identity.did,
        pubKey: @identity.pubkey,
        credentials: [],
      },
    }

    transaction(10, payload, sign(payload.to_json))
  end

  def transaction(code, payload, signature)
    {
      payload: [code, payload],
      signature: {
        signatureValue: [1, signature],
        created: Time.now.utc.iso8601(3),
      },
    }
  end
end
