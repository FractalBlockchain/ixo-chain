module IxoChain
  module Sovrin
    module Crypto
      class InvalidDidDoc < StandardError; end

      def self.signing_key(private_key)
        Ed25519::SigningKey.new(private_key)
      end

      def self.sign(private_key, bytes)
        private_key.sign(bytes)
      end

      def self.verify_signature(payload, verify_key, signature_hexed)
        verify_key_bytes = Base58.base58_to_binary(verify_key, :bitcoin)
        verify_key = Ed25519::VerifyKey.new(verify_key_bytes)
        signature_bytes = Hex.decode(signature_hexed)

        begin
          verify_key.verify(signature_bytes, payload)
          true
        rescue ArgumentError # Ed25519
          false
        end
      rescue Hex::EncodingError
        false
      rescue Ed25519::VerifyError
        false
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
    end
  end
end
