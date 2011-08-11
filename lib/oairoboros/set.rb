module OAIroboros
  class Set
    attr_reader :spec, :name, :description
    
    def initialize(client, spec, name=nil, description=nil)
      @client = client
      @spec = spec
      @name = name
      @description = description
    end
    
    def list_records(options={})
      @client.list_records(options.merge({:set=>@spec}))
    end
    
    def list_identifiers(options={})
      @client.list_identifiers(options.merge({:set=>@spec}))
    end    
  end
  
end