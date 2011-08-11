module OAIroboros
  class Record
    attr_reader :identifier, :datestamp, :sets, :metadata, :about, :metadata_prefix
    def initialize(client, record, metadata_prefix)
      @client = client
      @metadata_prefix = metadata_prefix
      parse_record(record)
    end
    
    def parse_record(rec)
      ns = {"oai"=>"http://www.openarchives.org/OAI/2.0/"}
      rec.xpath('./oai:header/oai:identifier', ns).each do |ident|
        @identifier = ident.inner_text
      end
      rec.xpath('./oai:header/oai:datestamp', ns).each do |date|
        @datestamp = date.inner_text
      end      
      rec.xpath('./oai:header/oai:setSpec', ns).each do |spec|
        @sets ||= []
        @sets << Set.new(@client, spec.inner_text)
      end 
      rec.xpath('./oai:metadata', ns).each do |metadata|
        @metadata = metadata
      end           
      rec.xpath('./oai:about', ns).each do |about|
        @about = about
      end      
    end
  end
end