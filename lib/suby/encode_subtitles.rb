require 'charlock_holmes'

class String

  COMMON_ENCODINGS = {
      fr: 'ISO-8859-1',
      cs: 'windows-1250'
  }

  # tries to encode string to UTF-8 according
  # to widely used encodings for specified language
  # yields if string was encoded
  def encode_to_utf8(lang)
    detected = CharlockHolmes::EncodingDetector.detect(self)[:encoding]
    # already in utf8 - nothing to do
    if detected == 'UTF-8'
      content
    else # try widely used encoding or best guess detect
      if String::COMMON_ENCODINGS.has_key? lang
        selected = String::COMMON_ENCODINGS[lang]
      else
        selected = detected
      end
      original = encoding
      force_encoding(selected)
      if valid_encoding?
        yield selected if block_given?
        encode!('UTF-8')
      else
        force_encoding(original)
      end
      self
    end
  end
end