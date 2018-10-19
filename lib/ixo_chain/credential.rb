module IxoChain
  module Credential
    def self.generate(type:, issuer_did:, issued_at: nil, claim:)
      {
        credential: {
          type: type,
          issuer: issuer_did,
          issued: issued_at || API.timestamp,
          claim: claim,
        },
      }
    end
  end
end
