require_relative 'downloader'
require 'xmlrpc/client'

module Suby

  class XMLRPCDownloader < Downloader

    def xmlrpc
      @xmlrpc ||= XMLRPC::Client.new(self.class::SITE, self.class::XMLRPC_PATH).tap do |xmlrpc|
        xmlrpc.http_header_extra = { 'accept-encoding' => 'identity' } if RbConfig::CONFIG['MAJOR'] == '2'
      end
    end
  end
end