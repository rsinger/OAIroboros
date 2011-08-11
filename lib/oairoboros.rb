module OAIroboros
  require 'typhoeus'
  require 'nokogiri'
  require File.dirname(__FILE__) + '/oairoboros/oai_response'     
  require File.dirname(__FILE__) + '/oairoboros/get_record_response'
  require File.dirname(__FILE__) + '/oairoboros/identify_response'
  require File.dirname(__FILE__) + '/oairoboros/list_identifiers_response'  
  require File.dirname(__FILE__) + '/oairoboros/list_metadata_formats_response'  
  require File.dirname(__FILE__) + '/oairoboros/list_records_response'  
  require File.dirname(__FILE__) + '/oairoboros/list_sets_response'  
  require File.dirname(__FILE__) + '/oairoboros/set'    
  require File.dirname(__FILE__) + '/oairoboros/resumption_token'   
  require File.dirname(__FILE__) + '/oairoboros/record'        
  
  class Client
    attr_reader :hydra, :queue, :host, :http_options
    def initialize(host, http_options={}, hydra_options={})
      @hydra = Typhoeus::Hydra.new(hydra_options)
      @host = host
      @http_options = http_options
      @queue = []
    end
        
    def run
      @hydra.run
      clean_queue
    end
    
    def clean_queue
      requests_run = @queue.find_all {|q| q.handled_response }
      @queue = @queue - requests_run
      requests_run
    end
    
    def camel_case(str)
      str2 = str.dup
      new_str = str.split("_").reverse.pop.downcase
      str2.sub!(new_str, "")
      str2.split("_").each do |word|
        new_str << word.capitalize
      end
      new_str
    end
    
    def default_metadata_prefix=(prefix)
      @default_metadata_prefix = prefix
    end
    
    def default_metadata_prefix
      @default_metadata_prefix||"oai_dc"
    end

    def identify;queue_verb_request("Identify");end
    def get_record(options);queue_verb_request("GetRecord", options);end    
    def list_identifiers(options={});queue_verb_request("ListIdentifiers", options);end    
    def list_metadata_formats(options={});queue_verb_request("ListMetadataFormats", options);end        
    def list_records(options={});queue_verb_request("ListRecords", options);end    
    def list_sets(options={});queue_verb_request("ListSets", options);end    
    
    def check_options(verb, options)   
      opts = options.dup
      opts.each_key do |key|
        if key =~ /\w_\w/
          new_key = camel_case(key.to_s)
          opts[new_key] = opts[key]
          opts.delete(key)
        end
      end
      unless ["Identify", "ListMetadataFormats", "ListSets"].include?(verb) && !opts["metadataPrefix"]
        opts["metadataPrefix"] = default_metadata_prefix
      end
      opts
    end 
        
    def queue_verb_request(verb, options={})            
      options = check_options(verb, options)
      request = Typhoeus::Request.new(@host, {:params=>{:verb=>verb}.merge(options)}.merge(@http_options))
      request.on_complete do |response|
        if response.success?
          OAIroboros.const_get(verb+"Response").new(self, response, options)
        elsif response.timed_out?
          @hydra.queue request
        elsif response.code == 0
          # Could not get an http response, something's wrong.
          #log(response.curl_error_message)
        else
          # Received a non-successful http response.
          #log("HTTP request failed: " + response.code.to_s)
        end
      end
      @queue << request
      @hydra.queue request
    end    
  end
end