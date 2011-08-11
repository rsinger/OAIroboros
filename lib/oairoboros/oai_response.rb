module OAIroboros
  module OAIResponse
    attr_reader :verb, :request_uri, :response_date, :set, :from, :until, :metadata_prefix
    def next?
      case 
      when @resumption_token then true
      else false
      end
    end
  
    private
  
    def ns
      {"oai"=>"http://www.openarchives.org/OAI/2.0/"}
    end
  
    def parse_oai_response
      @parsed_response.xpath('/oai:OAI-PMH/oai:responseDate', ns).each do |response_date_node|
        @response_date = response_date_node.inner_text
      end
      @parsed_response.xpath('/oai:OAI-PMH/oai:request', ns).each do |request_node|      
        @verb = request_node['verb']
        @set = request_node['set']
        @metadata_prefix = request_node['metadataPrefix']
        @from = request_node['from']
        @until = request_node['from']        
        @uri = request_node.inner_text
      end    
    end
  
    def parse?
      @options.fetch(:parse, true)
    end  
  
    def regex_for_resumption_token
      if match = @response.body.match(/\<resumptionToken[^\>]*\>([^\<]*)\<\/resumptionToken\>/)
        @resumption_token = ResumptionToken.new(match[1])
      end
    end  
  
  end
end