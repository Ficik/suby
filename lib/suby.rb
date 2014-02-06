require 'path'
require 'mime/types'
require 'logger'

Path.require_tree 'suby', except: %w[downloader/]

module Suby

  class Suby
    SUB_EXTENSIONS = %w[srt sub]

    def initialize(options, logger = nil)
      @manager = Manager.new(logger)
      @langs = options[:langs]
      @encode = options[:encode]
      @force = options[:force]
      @lang_ext = options[:langext]
    end

    def download_subtitles(files)
      files.each do |file|
        file = Path(file)
        if file.dir?
          download_subtitles(file.children)
        elsif video? file
            download_subtitles_for_file(file)
        end
      end
    end

    def has_subtitles?(file, lang)
      SUB_EXTENSIONS.any? do |type|
        file.sub_ext(file_extension(lang, type)).exists?
      end
    end

    def file_extension(lang, type)
      @lang_ext ? "#{lang}.#{type}" : type
    end

    def download_subtitles_for_file(file)
      @langs.each do |lang|
        if @force ||  (!has_subtitles? file, lang)
          data, type = @manager.get_subtitles(file, lang, @encode)
          unless data.nil?
            sub_file = file.sub_ext(file_extension(lang, type))
            File.open(sub_file, 'w') { |f| f.write data }
          end
        end
      end
    end

    def video?(file)
      MIME::Types.type_for(file.path).any? { |type| type.media_type == "video" }
    end
  end

end
