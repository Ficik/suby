require 'net/http'
require 'cgi/util'
require 'nokogiri'
require 'zlib'
require 'stringio'
require 'zip'
require_relative 'subtitles'

module Suby
  class Downloader

    NAME = "Unnamed downloader"

    def name
      self.class::NAME
    end

    def download_file(url, format = :plain)
      data = Net::HTTP.get(URI(url))
      if format == :plain
        data
      elsif format == :gz
        Zlib::GzipReader.new(StringIO.new(data)).read
      end
    end

    def parse_filename(file)
      FilenameParser.parse(file);
    end

    def clear_filename(file)
      p =parse_filename file
      if p[:type] == :tvshow
        "#{p[:name]} s#{"%02d" % p[:season]}e#{"%02d" % p[:episode]}"
      elsif p[:type] == :movie
        "#{p[:name]} (#{p[:year]})"
      else
        "#{p[:name]}"
      end
    end

  end
end
