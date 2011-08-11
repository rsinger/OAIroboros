module OAIroboros
  class ResumptionToken < String
    attr_accessor :expiration_date, :complete_list_size, :cursor
  end
end