module Hex
  class EncodingError < StandardError; end

  def self.encode(string)
    string.unpack1("H*").upcase
  end

  def self.decode(string)
    raise EncodingError unless hex?(string)

    [string].pack("H*")
  end

  def self.hex?(string)
    /\A[0-9A-F]*\z/.match?(string.upcase)
  end
end
