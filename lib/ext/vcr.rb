module VCR
  def self.insert_cassettes(cassettes)
    cassettes.each { insert_cassette _1, erb: true }
    yield
    cassettes.each { eject_cassette }
  end
end
