module OAIroboros
  class GetRecordResponse
    attr_reader :response, :parsed_response
    def initialize(client, response)
      @client = client
      @response = response
      @parsed_response = Nokogiri::XML(response.body) if response.body && !response.body.empty?
    end
  end
end