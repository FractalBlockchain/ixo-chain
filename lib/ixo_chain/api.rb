module IxoChain
  class API
    class InvalidEnvironment < StandardError; end

    ENVIRONMENTS = {
      production: "explorer",
      uat: "explorer_uat",
      qa: "explorer_qa",
    }.freeze

    def initialize(environment: :production)
      raise InvalidEnvironment unless ENVIRONMENTS.include?(environment.to_sym)

      @environment = environment
    end

    def register_did(did:, public_key:, signature:)
      payload = {
        didDoc: {
          did: did,
          pubKey: public_key,
          credentials: [],
        },
      }

      broadcast transaction(10, payload, signature)
    end

    def register_credential(credential:, signature:)
      broadcast transaction(24, credential, signature)
    end

    def transaction(code:, payload:, signature:)
      {
        payload: [code, payload],
        signature: {
          signatureValue: [1, signature],
          created: self.class.timestamp,
        },
      }
    end

    def broadcast(transaction)
      uri = URI("#{url}/blockchain/0x#{Hex.encode(transaction)}")
      Net::HTTP.get_response(uri)
    end

    def url
      @url ||= "https://#{ENVIRONMENTS[@environment]}.ixo.world/api"
    end

    def self.timestamp(time = Time.now)
      time.utc.iso8601(3)
    end
  end
end
