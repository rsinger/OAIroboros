module OAIroboros
  class ListRecordsResponse
    include OAIResponse
    attr_reader :response, :parsed_response, :records, :resumption_token
    def initialize(client, response, options)
      @client = client
      @response = response
      @options = options
      if parse?
        @parsed_response = Nokogiri::XML(response.body) if response.body && !response.body.empty?
        @records = []
        parse_oai_response
        parse_response
      else
        regex_for_resumption_token
      end
    end
    
    def next(options={})
      return unless next?
      @client.list_records(options.merge({:resumption_token=>@resumption_token}))
    end
            
    def parse_response
      @parsed_response.xpath('/oai:OAI-PMH/oai:ListRecords/oai:record',ns).each do |rec|    
        @records << Record.new(@client, rec, @metadata_prefix)
      end
      @parsed_response.xpath('/oai:OAI-PMH/oai:ListSets/oai:resumptionToken',ns).each do |rt|
        @resumption_token = ResumptionToken.new(rt.inner_text)
        @resumption_token.expiration_date = rt['expirationDate']
        @resumption_token.complete_list_size = rt['completeListSize']
        @resumption_token.cursor = rt['cursor']
      end      
    end
  end
end