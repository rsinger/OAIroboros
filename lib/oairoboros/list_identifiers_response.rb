module OAIroboros
  class ListIdentifiersResponse
    attr_reader :response, :parsed_response
    def initialize(client, response, options)
      @client = client
      @response = response
      @options = options
      if parse?
        @parsed_response = Nokogiri::XML(response.body) if response.body && !response.body.empty?
      else
        regex_for_resumption_token
      end
    end
  end
end