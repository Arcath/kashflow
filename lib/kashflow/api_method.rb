module Kashflow
  class ApiMethod
    attr_accessor :name, :request_attrs, :response_attrs
  
    def initialize(name, fields)
      @name = name
        
      # split into request/response attrs
      @request_attrs, @response_attrs = fields.partition{|f| f[:direction] == 'IN' }.map do |arr| 
        arr.map do |fields| 
          # get rid of the :direction and cleanup the description text
          fields.slice!(:type, :desc, :name)
          fields[:desc].try(:strip!)
          fields
        end
      end
    end
  end
end
