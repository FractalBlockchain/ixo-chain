require "minitest/autorun"
require "ixo_chain"

class IxoDidTest < Minitest::Test
  identity = SovrinIdentity.new(SecureRandom.bytes(32))
  ixo = {
    diddoc: {
      "did" => identity.did,
      "pubKey" => identity.pubkey,
    },
    nonce: "fractal:sign:0e6fe770-26c8-48c9-9730-54b417a28e74",
  }

  describe "#valid_diddoc?" do
    it "is invalid if the diddoc doesn't have the right keys" do
      refute IxoDid.valid_diddoc?({})
      refute IxoDid.valid_diddoc?("did" => "derp")
      refute IxoDid.valid_diddoc?("pubKey" => "herp")
      refute IxoDid.valid_diddoc?("did" => "herp", "pubkey" => "derkaderka")
    end

    it "is invalid if the diddoc has malformed (non-base58) pubKey" do
      refute IxoDid.valid_diddoc?("did" => "derp", "pubKey" => "_")
    end

    it "is invalid if the did doesn't match the pubKey" do
      refute IxoDid.valid_diddoc?(
        "did" => "did:sov:invalid",
        "pubKey" => identity.pubkey,
      )

      refute IxoDid.valid_diddoc?(
        "did" => identity.did,
        "pubKey" => "invalid",
      )
    end

    it "is valid only if the did matches the pubKey" do
      assert IxoDid.valid_diddoc?(
        "did" => identity.did,
        "pubKey" => identity.pubkey,
      )
    end
  end

  describe "#verify_nonce_signature" do
    describe "when signature, nonce and key match" do
      let(:valid_signature) { Hex.encode(identity.sign(ixo[:nonce])) }

      it "returns true" do
        assert IxoDid.verify_nonce_signature(
          ixo,
          valid_signature,
        )
      end
    end

    describe "when signature, nonce or key don't match" do
      it "returns false" do
        refute IxoDid.verify_nonce_signature(
          ixo,
          "invalid",
        )
      end
    end
  end

  describe "#generate_nonce" do
    it "assigns prefix" do
      assert IxoDid.generate_nonce(prefix: "derp").start_with?("derp:sign:")
    end

    it "is pretty random, right?" do
      assert_equal 10_000, Array.new(10_000) { IxoDid.generate_nonce }.uniq.size
    end
  end
end
