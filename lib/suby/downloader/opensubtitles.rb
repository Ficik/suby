require_relative '../xmlrpc_downloader'

module Suby

  class Downloader::OpenSubtitles < XMLRPCDownloader

    NAME = 'OpenSubtitles'

    SITE = 'api.opensubtitles.org'
    XMLRPC_PATH = '/xml-rpc'
    LOGIN_LANGUAGE = 'eng'
    USERNAME = ''
    PASSWORD = ''

    USER_AGENT = 'Suby v2.0'

    FORMAT = :gz
    SUBTITLE_TYPES = [:tvshow, :movie, :unknown]
    SEARCH_QUERIES_ORDER = [:hash, :name] #There is also search using imdbid but i dont think it usefull as it
                                          #returns subtitles for many different versions

    # OpenSubtitles needs ISO 639-22B language codes for subtitles search
    # See http://www.opensubtitles.org/addons/export_languages.php
    # and http://en.wikipedia.org/wiki/List_of_ISO_639-2_codes
    LANG_MAPPING = {
      ar: "ara", bg: "bul", bn: "ben", br: "bre", bs: "bos", ca: "cat", cs: "cze", da: "dan", de: "ger", el: "ell",
      en: "eng", eo: "epo", es: "spa", et: "est", eu: "baq", fa: "per", fi: "fin", fr: "fre", gl: "glg", he: "heb",
      hi: "hin", hr: "hrv", hu: "hun", hy: "arm", id: "ind", is: "ice", it: "ita", ja: "jpn", ka: "geo", kk: "kaz",
      km: "khm", ko: "kor", lb: "ltz", lt: "lit", lv: "lav", mk: "mac", mn: "mon", ms: "may", nl: "dut", no: "nor",
      oc: "oci", pb: "pob", pl: "pol", pt: "por", ro: "rum", ru: "rus", si: "sin", sk: "slo", sl: "slv", sq: "alb",
      sr: "scc", sv: "swe", sw: "swa", th: "tha", tl: "tgl", tr: "tur", uk: "ukr", ur: "urd", vi: "vie", zh: "chi"
    }
    LANG_MAPPING.default = 'all'

    OpenSubtitle = SubtitlePromise.create do
      attr_accessor :release_name, :rating

      def calculate_rank
        0
      end

    end

    def search(file, lang)
      parsed = parse_filename(file)
      subs = search_subtitles(query_by_name(parsed), language(lang))
      subs_hash = search_subtitles(query_by_hash(file), language(lang))

      subs['data'] = [] unless subs['data']
      subs_hash['data'] = [] unless subs_hash['data']
      subs = (subs['data'] + subs_hash['data']).map do |s|

        sub = OpenSubtitle.new
        sub.rating = s['SubRating']
        sub.release_name = s['MovieReleaseName']
        sub.url = s['SubDownloadLink']
        sub
      end
      subs
    end

    def download(sub)
      download_file(sub.url, :gz)
    end

    def search_subtitles(query, lang = false)
      return {} unless query
      query[:sublanguageid] = lang if lang
      query = [query] unless query.kind_of? Array
      xmlrpc.call('SearchSubtitles', token, query)
    end

    def token
      @token ||= login
    end

    def login
      response = xmlrpc.call('LogIn', USERNAME, PASSWORD, LOGIN_LANGUAGE, USER_AGENT)
      unless response['status'] == '200 OK'
        raise DownloaderError, "Failed to login with #{USERNAME}:#{PASSWORD}. " +
                               "Server return code: #{response['status']}"
      end
      response['token']
    end

    def query_by_name(parsed)
      if parsed[:type] == :tvshow
        {
            query: parsed[:name],
            season: parsed[:season],
            episode: parsed[:episode]
        }
      else
        { query: parsed[:name] }
      end
    end

    def query_by_hash(file)
      { moviehash: MovieHasher.compute_hash(file), moviebytesize: file.size.to_s } if file.exist?
    end

    def language(lang)
      LANG_MAPPING[lang.to_sym]
    end

  end
end
