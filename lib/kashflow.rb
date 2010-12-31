require 'ostruct'
require 'savon'

require File.expand_path('../kashflow/client', __FILE__)
require File.expand_path('../kashflow/api_method', __FILE__)
require File.expand_path('../kashflow/api', __FILE__)

module Kashflow
  def self.client(login, password)
    @client ||= Kashflow::Client.new(login, password)
  end
  
  def self.method_missing(method, *args, &block)
    return super unless client.respond_to?(method)
    client.send(method, *args, &block)
  end
  
  def self.root
    File.dirname(File.expand_path('..', __FILE__))
  end
end