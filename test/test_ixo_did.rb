require "minitest/autorun"
require "ixo_chain"

class IxoChain::IxoDidTest < Minitest::Test
  identity = IxoChain::Sovrin::Identity.new(SecureRandom.bytes(32))

  describe "#valid_diddoc?" do
    it "is invalid if the diddoc doesn't have the right keys" do
      refute IxoChain::Sovrin::Crypto.valid_diddoc?({})
      refute IxoChain::Sovrin::Crypto.valid_diddoc?("did" => "derp")
      refute IxoChain::Sovrin::Crypto.valid_diddoc?("pubKey" => "herp")
      refute IxoChain::Sovrin::Crypto.valid_diddoc?("did" => "herp", "pubkey" => "derkaderka")
    end

    it "is invalid if the diddoc has malformed (non-base58) pubKey" do
      refute IxoChain::Sovrin::Crypto.valid_diddoc?("did" => "derp", "pubKey" => "_")
    end

    it "is invalid if the did doesn't match the pubKey" do
      refute IxoChain::Sovrin::Crypto.valid_diddoc?(
        "did" => "did:sov:invalid",
        "pubKey" => identity.pubkey,
      )

      refute IxoChain::Sovrin::Crypto.valid_diddoc?(
        "did" => identity.did,
        "pubKey" => "invalid",
      )
    end

    it "is valid only if the did matches the pubKey" do
      assert IxoChain::Sovrin::Crypto.valid_diddoc?(
        "did" => identity.did,
        "pubKey" => identity.pubkey,
      )
    end
  end

  describe "#verify_signature" do
    let(:payload) { "message to sign" }

    describe "when signature, nonce and key match" do
      let(:valid_signature) { Hex.encode(identity.sign(payload)) }

      it "returns true" do
        assert IxoChain::Sovrin::Crypto.verify_signature(
          payload,
          identity.pubkey,
          valid_signature,
        )
      end
    end

    describe "when signature, nonce or key don't match" do
      it "returns false" do
        refute IxoChain::Sovrin::Crypto.verify_signature(
          payload,
          identity.pubkey,
          "invalid",
        )
      end
    end
  end
end
