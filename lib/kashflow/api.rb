require 'open-uri'
require 'nokogiri'
require 'active_support/core_ext/object'
require 'active_support/core_ext/hash'

## Kashflow.export_yaml will scrape the public API site for methods and 
## dump them into the YAML config we use. we probably can/should just get this
## from the WSDL directly, but Savon wasn't working right, so this is the stopgap measure
module Kashflow
  class Api
    class << self
      
      def api_page(path)
        cache_path = File.join(Kashflow.root, 'tmp', 'kf_api_pages', path)
        
        unless File.exists?(cache_path)
          File.open(cache_path, 'w'){ |f| f << open("http://accountingapi.com/#{path}").read }
        end
      
        Nokogiri::HTML(open(cache_path))
      end
      
      def apis_from_web
        main_page = api_page('manual_class_customer.asp')
        
        main_page.search('#mr_manual_inner a').select do |node|
          node['href'] =~ /manual_methods/ and
          node['href'] != 'manual_methods_overview.asp'
      
        end.map{|n| new(n.content, n['href']) }
      end
      
      def export_yaml
        api_methods = apis_from_web.map { |a| ApiMethod.new(a.name, a.import) }
        
        File.open(Client.yaml_path, 'w') do |f|
          YAML.dump(api_methods, f)
        end
      end
    
    end
  
    attr_reader :name, :page
    def initialize(name, page)
      @name = name
      @page = page
    end
  
    def api_page
      @api_page ||= self.class.api_page(page)
    end
  
    def import
      @fields ||= api_page.search('.mnl_tbl1 tr').map do |row|
        {
          :name       => row.search('span.mnl_varName').first.try(:content),
          :type       => row.search('span.mnl_varType').first.try(:content),
          :direction  => row.search('td strong').first.try(:content),
          :desc       => row.search('td').last.try(:content)
        }
      end
    end
  end
end
