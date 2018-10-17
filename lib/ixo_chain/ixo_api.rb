module IxoAPI
  def self.broadcast(transaction)
    uri = URI("#{ENV["IXO_API_BASE_URL"]}/api/blockchain/0x#{Hex.encode(transaction)}")
    Net::HTTP.get_response(uri)
  end
end
