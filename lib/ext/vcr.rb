module VCR
  def self.insert_provider_cassettes(provider, cassettes, &block)
    insert_cassettes cassettes.map { "providers.#{provider}.#{_1}" }, &block
  end

  def self.insert_cassettes(cassettes)
    cassettes.each { insert_cassette _1, erb: true }
    yield
    cassettes.each { eject_cassette }
  end
end
