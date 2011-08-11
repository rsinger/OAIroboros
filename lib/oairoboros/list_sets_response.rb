module OAIroboros
  class ListSetsResponse
    include OAIResponse
    attr_reader :response, :parsed_response, :sets, :headers, :resumption_token
    def initialize(client, response, options)
      @client = client
      @response = response
      @options = options
      if parse?
        @parsed_response = Nokogiri::XML(response.body) if response.body && !response.body.empty?   
        @sets = []  
        parse_oai_response 
        parse_response
      else
        regex_for_resumption_token
      end
    end
    
    def next(options={})
      return unless next?
      @client.list_sets(options.merge({:resumption_token=>@resumption_token}))
    end    
    
    private
    def parse_response
      @parsed_response.xpath('/oai:OAI-PMH/oai:ListSets/oai:set',ns).each do |set|
        props = {}
        set.xpath("./oai:setSpec", ns).each do |spec|
          props[:spec] = spec.inner_text
        end
        set.xpath("./oai:setName", ns).each do |name|
          props[:name] = name.inner_text
        end 
        set.xpath("./oai:setDescription", ns).each do |desc|
          props[:description] = desc
        end               
        @sets << Set.new(@client, props[:spec], props[:name], props[:description])
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