module Suby

  class DownloaderInitializationException < StandardError

    def initialize(downloader, e)
      super("Could not initialize downloader #{downloader}: #{e.message}")
    end

  end

  class DownloaderError < StandardError
  end

end