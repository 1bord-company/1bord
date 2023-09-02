module ResourceClient
  module CompressedResponse
    private

    def response_body = Zlib::GzipReader.new(StringIO.new @response.body).read
  end
end
