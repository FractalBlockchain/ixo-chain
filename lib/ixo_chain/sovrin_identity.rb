class SovrinIdentity
  attr_reader :private_key

  def initialize private_key
    @private_key = Ed25519::SigningKey.new(private_key)
  end

  def did
    @did ||= "did:sov:#{encoded(private_key.verify_key.to_bytes[0...16])}"
  end

  def pubkey
    @pubkey ||= encoded(private_key.verify_key.to_bytes)
  end

  def sign(bytes)
    private_key.sign(bytes)
  end

  private

  def encoded(bytes)
    Base58.binary_to_base58(bytes, :bitcoin, true)
  end
end
