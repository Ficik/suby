module Suby
  class SubtitlePromise

    attr_accessor :file, :lang, :downloader
    attr_accessor :url

    def self.create(&block)
      klass = Class.new(SubtitlePromise)
      if block_given?
        klass.instance_eval(&block)
      end
      klass
    end

    def download
      @downloader.download(self)
    end

    # one should override this method to rank subtitles match
    # of set @rank value directly
    # rank should be in range 0 - 100 where 100 is exact match
    def calculate_rank
      0
    end

    # @returns rank
    def rank
      if @rank.nil?
        @rank = calculate_rank
      end
      @rank
    end

    # calculate rank by filename match
    def calculate_rank_by_filename(filename)
      # TODO: improve matching logic
      filename.downcase == @file.downcase ? 100 : 0
    end
  end
end