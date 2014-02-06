require 'nokogiri'
require 'open-uri'
require_relative '../downloader'

module Suby

  class Downloader::TitulkyCom < Downloader

    NAME = 'Titulky.com'

    Titulky = SubtitlePromise.create do

      attr_accessor :releases, :size, :lang, :down

    end

    def search(file, lang)
      return if lang != :cs && lang != :sk
      cleared = clear_filename(file)
      query_search(cleared).select {|s| s.lang == lang}
    end

    def query_search(name)
      url = "http://www.titulky.com/index.php?Fulltext=#{name.gsub(' ','+')}"
      doc = Nokogiri::HTML(open(url))
      doc.css('.soupis tr[class]').map do |row|
        sub = Titulky.new
        id = (row.css('td:first-child a').attr('href').value.match /.*-(\d+).htm/)[1]
        sub.url    = "http://www.titulky.com/idown.php?titulky=#{"%010d" % id.to_i}"
        sub.down   = row.css('td:nth-child(5)').text.to_i
        sub.lang   = row.css('td:nth-child(6) img').attr('alt').value == 'CZ' ? :cs : :sk
        sub.size   = row.css('td:nth-child(8)').text.to_i
        r = row.css('td:nth-child(2) a')
        if r && r.attr('title')
          r = r.attr('title').value
          sub.releases = r.split(',').map {|t| t.strip}
        else
          sub.releases = []
        end
        sub
      end
    end

    def download(sub)
      puts "downloading #{sub.url}"
      doc = Nokogiri::HTML(open(sub.url))
      url = 'http://www.titulky.com/' + doc.css('#downlink').attr('href').value
      delay = doc.css('body').attr('onload').value.sub('CountDown(','').to_i
      sleep delay
      download_file(url, :plain)
    end

  end
end