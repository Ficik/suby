require_relative 'exceptions/exceptions'
require_relative 'encode_subtitles'

module Suby
  # Manages downloaders and provides api to seach any of them
  class Manager

    DOWNLOADERS = {}

    attr_reader :loaded_downloaders

    def initialize(logger = nil)
      if logger.nil?
        require 'logger'
        logger = Logger.new(STDOUT);
      end
      @logger = logger
      @downloaders = {}
      @loaded_downloaders = []
    end

    def get_subtitles(file, lang, encode)
      initialize_downloaders if @loaded_downloaders.empty?
      subtitles = find_available_subtitles(file, lang)
      if subtitles.empty?
        @logger.warn("No #{lang} subtitles found for #{file.basename}")
        return nil
      else
        subtitles.sort_by { |s| s.rank}
        sub = subtitles.first
        content = sub.download
        encode_msg = ''
        if encode
          content.encode_to_utf8(lang) do |encoding|
            encode_msg = " (transcoded to #{encoding})"
          end
        end
        @logger.info("Subtitles downloaded by #{sub.downloader.name}#{encode_msg}")
        [content, sub_extension(content)]
      end
    end

    # agregated subtitles lookup
    def find_available_subtitles(file, lang)
      initialize_downloaders if @loaded_downloaders.empty?
      subtitles = @loaded_downloaders.map do |downloader|
        begin
          # TODO: log success/error
          subs = downloader.search(file, lang)
          subs = [] if subs.nil?
          subs.each do |sub|
            sub.downloader = downloader
            sub.file = file
            sub.lang = lang
          end
          @logger.debug "#{downloader.name} found #{subs.length} #{lang} subtitles for #{file.basename}"
          subs
        rescue StandardError => e
          @logger.error "Search of #{downloader.name} failed: #{e}"
          return []
        end
      end
      subtitles.flatten
    end

    def sub_extension(contents)
      if contents[0..10] =~ /1\r?\n/
        'srt'
      else
        'sub'
      end
    end

    #########################
    # Downloader managment
    #########################

    def available_downloaders
      @downloaders.keys.map(:to_s);
    end

    def self.downloaders
      DOWNLOADERS
    end

    # register downloader
    # @param name name to be shown
    def self.register_downloader(name, class_name, path)
      DOWNLOADERS[name.to_sym] = {
          path: path,
          cls: class_name,
          name: name
      }
    end

    def initialize_downloaders()
      DOWNLOADERS.keys.each do |name|
        begin
          @loaded_downloaders << initialize_downloader(name)
        rescue DownloaderInitializationException => e
          @logger.error e.to_s
        end
      end
    end

    private

    # lazy loading of downloader
    def initialize_downloader(name)
      begin
        require DOWNLOADERS[name][:path]
        Object.const_get(DOWNLOADERS[name][:cls]).new
      rescue StandardError => e
        raise DownloaderInitializationException.new(name.to_s, e)
      end
    end

  end
end

require_relative 'downloader/standard_downloaders'