module FriendlyId
  module SlugGenerator
    extend self

    def parameterize(string : String, separator : String = "-", preserve_case : Bool = false, locale : String? = nil) : String
      return "" if string.nil? || string.strip.empty?

      # Remove # if present at the beginning
      clean_string = string.strip
      clean_string = clean_string.starts_with?("#") ? clean_string[1..-1] : clean_string

      return "" if clean_string.empty?

      # Check if the string contains non-Latin characters
      if contains_non_latin_script?(clean_string)
        return parameterize_non_latin(clean_string, separator, preserve_case)
      end

      # Start with transliteration for ASCII equivalents
      parameterized_string = transliterate(clean_string, locale)

      # Handle separator patterns
      re_duplicate_separator = separator == "-" ? /-{2,}/ : /#{Regex.escape(separator)}{2,}/
      re_leading_trailing_separator = separator == "-" ? /^-|-$/i : /^#{Regex.escape(separator)}|#{Regex.escape(separator)}$/i

      # Process the string
      parameterized_string = parameterized_string
        .gsub(/[^a-z0-9\-_]+/i, separator)
        .gsub(re_duplicate_separator, separator)
        .gsub(re_leading_trailing_separator, "")

      result = preserve_case ? parameterized_string : parameterized_string.downcase

      # Ensure not empty
      result.empty? ? "tag" : result
    end

    # Improved method to handle non-Latin scripts (CJK, Cyrillic, Devanagari, Arabic, etc.)
    def parameterize_non_latin(string : String, separator : String = "-", preserve_case : Bool = false) : String
      # First try to extract any Latin characters for a readable slug
      latin_only = string.gsub(/[^\p{Latin}\p{N}\s\-_]/, "").strip

      if !latin_only.empty? && latin_only.size >= 2
        # If we have meaningful Latin characters, use them for the slug
        return parameterize(latin_only, separator, preserve_case)
      else
        # For non-Latin text, create a transliterated version
        transliterated = transliterate_extended(string)

        if !transliterated.empty? && transliterated != string
          # If transliteration worked, use it
          return parameterize(transliterated, separator, preserve_case)
        else
          # As last resort, create a hash-based slug with script prefix
          prefix = detect_script_prefix(string)
          hash_part = string.hash.abs.to_s(36)[0..7]

          result = "#{prefix}-#{hash_part}"
          preserve_case ? result : result.downcase
        end
      end
    end

    # Helper method to detect non-Latin scripts
    def contains_non_latin_script?(string : String) : Bool
      string.each_char do |char|
        code_point = char.ord
        # Skip ASCII and Latin Extended characters
        next if code_point < 0x0080 || (0x00C0 <= code_point && code_point <= 0x024F)
        # Skip common punctuation and symbols
        next if (0x2000 <= code_point && code_point <= 0x206F) || # General Punctuation
                (0x20A0 <= code_point && code_point <= 0x20CF)    # Currency Symbols

        # If we find any non-Latin character, return true
        return true
      end
      false
    end

    # Detect script and return appropriate prefix
    def detect_script_prefix(string : String) : String
      # Check for the dominant script in the string
      counts = Hash(String, Int32).new(0)

      string.each_char do |char|
        code_point = char.ord

        # CJK scripts
        if (0x4E00 <= code_point && code_point <= 0x9FFF) || # CJK Unified Ideographs
           (0x3040 <= code_point && code_point <= 0x309F) || # Hiragana
           (0x30A0 <= code_point && code_point <= 0x30FF) || # Katakana
           (0xAC00 <= code_point && code_point <= 0xD7AF)    # Hangul
          counts["cjk"] += 1
          # Cyrillic (Russian, etc.)
        elsif (0x0400 <= code_point && code_point <= 0x04FF)
          counts["cyr"] += 1
          # Devanagari (Hindi, etc.)
        elsif (0x0900 <= code_point && code_point <= 0x097F)
          counts["dev"] += 1
          # Arabic
        elsif (0x0600 <= code_point && code_point <= 0x06FF)
          counts["ara"] += 1
          # Hebrew
        elsif (0x0590 <= code_point && code_point <= 0x05FF)
          counts["heb"] += 1
          # Thai
        elsif (0x0E00 <= code_point && code_point <= 0x0E7F)
          counts["tha"] += 1
          # Greek
        elsif (0x0370 <= code_point && code_point <= 0x03FF)
          counts["gre"] += 1
          # Armenian
        elsif (0x0530 <= code_point && code_point <= 0x058F)
          counts["arm"] += 1
          # Georgian
        elsif (0x10A0 <= code_point && code_point <= 0x10FF)
          counts["geo"] += 1
          # Other non-Latin scripts
        else
          counts["oth"] += 1
        end
      end

      # Return the prefix for the most common script
      return "oth" if counts.empty?

      counts.max_by { |_, count| count }[0]
    end

    # Extended transliteration for more languages - MELHORADO
    private def transliterate_extended(string : String) : String
      # Mapa de caracteres mais abrangente
      char_map = {
        # Português/Espanhol/Francês - acentos comuns
        'á' => "a", 'à' => "a", 'ä' => "a", 'â' => "a", 'ā' => "a", 'ã' => "a", 'ą' => "a", 'ă' => "a",
        'é' => "e", 'è' => "e", 'ë' => "e", 'ê' => "e", 'ē' => "e", 'ę' => "e", 'ě' => "e",
        'í' => "i", 'ì' => "i", 'ï' => "i", 'î' => "i", 'ī' => "i", 'į' => "i", 'ĩ' => "i",
        'ó' => "o", 'ò' => "o", 'ö' => "o", 'ô' => "o", 'ō' => "o", 'õ' => "o", 'ő' => "o", 'ơ' => "o",
        'ú' => "u", 'ù' => "u", 'ü' => "u", 'û' => "u", 'ū' => "u", 'ů' => "u", 'ų' => "u", 'ư' => "u",
        'ý' => "y", 'ÿ' => "y", 'ỳ' => "y",
        'ñ' => "n", 'ń' => "n", 'ň' => "n", 'ņ' => "n",
        'ç' => "c", 'ć' => "c", 'ĉ' => "c", 'ċ' => "c", 'č' => "c",
        'ż' => "z", 'ź' => "z", 'ž' => "z",
        'ś' => "s", 'ŝ' => "s", 'ş' => "s", 'š' => "s",
        'ř' => "r", 'ŕ' => "r",
        'ł' => "l", 'ĺ' => "l", 'ļ' => "l", 'ľ' => "l",
        'đ' => "d", 'ď' => "d",
        'ť' => "t", 'ţ' => "t",
        'ğ' => "g", 'ģ' => "g",
        'ķ' => "k",

        # Versões maiúsculas
        'Á' => "A", 'À' => "A", 'Ä' => "A", 'Â' => "A", 'Ā' => "A", 'Ã' => "A", 'Ą' => "A", 'Ă' => "A",
        'É' => "E", 'È' => "E", 'Ë' => "E", 'Ê' => "E", 'Ē' => "E", 'Ę' => "E", 'Ě' => "E",
        'Í' => "I", 'Ì' => "I", 'Ï' => "I", 'Î' => "I", 'Ī' => "I", 'Į' => "I", 'Ĩ' => "I",
        'Ó' => "O", 'Ò' => "O", 'Ö' => "O", 'Ô' => "O", 'Ō' => "O", 'Õ' => "O", 'Ő' => "O", 'Ơ' => "O",
        'Ú' => "U", 'Ù' => "U", 'Ü' => "U", 'Û' => "U", 'Ū' => "U", 'Ů' => "U", 'Ų' => "U", 'Ư' => "U",
        'Ý' => "Y", 'Ÿ' => "Y", 'Ỳ' => "Y",
        'Ñ' => "N", 'Ń' => "N", 'Ň' => "N", 'Ņ' => "N",
        'Ç' => "C", 'Ć' => "C", 'Ĉ' => "C", 'Ċ' => "C", 'Č' => "C",
        'Ż' => "Z", 'Ź' => "Z", 'Ž' => "Z",
        'Ś' => "S", 'Ŝ' => "S", 'Ş' => "S", 'Š' => "S",
        'Ř' => "R", 'Ŕ' => "R",
        'Ł' => "L", 'Ĺ' => "L", 'Ļ' => "L", 'Ľ' => "L",
        'Đ' => "D", 'Ď' => "D",
        'Ť' => "T", 'Ţ' => "T",
        'Ğ' => "G", 'Ģ' => "G",
        'Ķ' => "K",

        # Acentos e símbolos especiais adicionais
        'å' => "a", 'ā' => "a", 'ă' => "a", 'ą' => "a",
        'ć' => "c", 'č' => "c", 'ç' => "c",
        'ē' => "e", 'ĕ' => "e", 'ě' => "e", 'ę' => "e",
        'ģ' => "g", 'ğ' => "g",
        'ī' => "i", 'ĭ' => "i", 'į' => "i",
        'ķ' => "k",
        'ļ' => "l", 'ł' => "l",
        'ń' => "n", 'ň' => "n", 'ņ' => "n",
        'ō' => "o", 'ŏ' => "o", 'ő' => "o",
        'ř' => "r", 'ŕ' => "r",
        'ś' => "s", 'š' => "s",
        'ū' => "u", 'ŭ' => "u", 'ů' => "u", 'ű' => "u",
        'ź' => "z", 'ž' => "z",
        'ß' => "ss",
        'æ' => "ae",
        'œ' => "oe",
        'ø' => "o",
        'ł' => "l",
        'đ' => "d",
        'ħ' => "h",
        "ı" => "i",
        'ł' => "l",
        'ŉ' => "n",
        'ŋ' => "n",
        'ř' => "r",
        'ś' => "s",
        'ť' => "t",
        'ū' => "u",
        'ŵ' => "w",
        'ŷ' => "y",
        'ź' => "z",
        'ż' => "z",
        'ǎ' => "a",
        'ǐ' => "i",
        'ǒ' => "o",
        'ǔ' => "u",
        'ǖ' => "u",
        'ǘ' => "u",
        'ǚ' => "u",
        'ǜ' => "u",
        'ǟ' => "a",
        'ȫ' => "o",
        'ǩ' => "k",
        'ǫ' => "o",
        'ǭ' => "o",
        'ǯ' => "z",
        'ǰ' => "j",
        'ǳ' => "dz",
        'ǵ' => "g",
        'ǹ' => "n",
        'ǻ' => "a",
        'ǽ' => "ae",
        'ǿ' => "o",
        'ȁ' => "a",
        'ȅ' => "e",
        'ȉ' => "i",
        'ȍ' => "o",
        'ȑ' => "r",
        'ȕ' => "u",
        'ȗ' => "u",
        'ș' => "s",
        'ț' => "t",
        'ȝ' => "g",
        "ȣ" => "ou",
        'ȥ' => "z",
        'ȧ' => "a",
        'ȩ' => "e",
        'ȷ' => "j",
        'ḁ' => "a",
        'ă' => "a",
        'ą' => "a",
        'ć' => "c",
        'č' => "c",
        'ç' => "c",
        'ḉ' => "c",
        'ḋ' => "d",
        'ḍ' => "d",
        'ḏ' => "d",
        'ḑ' => "d",
        'ḓ' => "d",
        'ē' => "e",
        'ĕ' => "e",
        'ė' => "e",
        'ę' => "e",
        'ě' => "e",
        'ḕ' => "e",
        'ḗ' => "e",
        'ḙ' => "e",
        'ḛ' => "e",
        'ḝ' => "e",
        'ḟ' => "f",
        'ḡ' => "g",
        'ğ' => "g",
        'ġ' => "g",
        'ģ' => "g",
        'ḣ' => "h",
        'ḥ' => "h",
        'ḧ' => "h",
        'ḩ' => "h",
        'ḫ' => "h",
        'ẖ' => "h",
        'ī' => "i",
        'ĭ' => "i",
        'į' => "i",
        "ı" => "i",
        'ḭ' => "i",
        'ḯ' => "i",
        'ḱ' => "k",
        'ḳ' => "k",
        'ķ' => "k",
        'ḵ' => "k",
        'ĺ' => "l",
        'ŀ' => "l",
        'ł' => "l",
        'ḷ' => "l",
        'ḹ' => "l",
        'ḻ' => "l",
        'ḿ' => "m",
        'ṁ' => "m",
        'ṃ' => "m",
        'ṅ' => "n",
        'ṇ' => "n",
        'ṉ' => "n",
        'ṋ' => "n",
        'ṍ' => "n",
        'ṏ' => "n",
        'ṑ' => "o",
        'ṓ' => "o",
        'ṕ' => "p",
        'ṗ' => "p",
        'ṙ' => "r",
        'ṛ' => "r",
        'ṝ' => "r",
        'ṟ' => "r",
        'ś' => "s",
        'ṣ' => "s",
        'ṥ' => "s",
        'ṧ' => "s",
        'ṩ' => "s",
        'ṫ' => "t",
        'ṭ' => "t",
        'ṯ' => "t",
        'ṱ' => "t",
        'ẗ' => "t",
        'ū' => "u",
        'ŭ' => "u",
        'ů' => "u",
        'ű' => "u",
        'ų' => "u",
        'ṷ' => "u",
        'ṻ' => "u",
        'ṽ' => "u",
        'ẃ' => "w",
        'ẅ' => "w",
        'ẇ' => "w",
        'ẉ' => "w",
        'ẘ' => "w",
        'ẍ' => "x",
        'ẋ' => "x",
        'ẏ' => "y",
        'ź' => "z",
        'ż' => "z",
        'ẓ' => "z",
        'ẕ' => "z",
        'ẛ' => "s",
        'ạ' => "a",
        'ả' => "a",
        'ấ' => "a",
        'ầ' => "a",
        'ẩ' => "a",
        'ẫ' => "a",
        'ậ' => "a",
        'ắ' => "a",
        'ằ' => "a",
        'ẳ' => "a",
        'ẵ' => "a",
        'ặ' => "a",
        'ẹ' => "e",
        'ẻ' => "e",
        'ẽ' => "e",
        'ế' => "e",
        'ề' => "e",
        'ể' => "e",
        'ễ' => "e",
        'ệ' => "e",
        'ỉ' => "i",
        'ị' => "i",
        'ọ' => "o",
        'ỏ' => "o",
        'ố' => "o",
        'ồ' => "o",
        'ổ' => "o",
        'ỗ' => "o",
        'ộ' => "o",
        'ớ' => "o",
        'ờ' => "o",
        'ở' => "o",
        'ỡ' => "o",
        'ợ' => "o",
        'ụ' => "u",
        'ủ' => "u",
        'ứ' => "u",
        'ừ' => "u",
        'ử' => "u",
        'ữ' => "u",
        'ự' => "u",
        'ỳ' => "y",
        'ỵ' => "y",
        'ỷ' => "y",
        'ỹ' => "y",
        'ỻ' => "ll",
        'ỽ' => "ll",
        'Ỿ' => "ll",
        "ỿ" => "ll",
        'ﬀ' => "ff",
        'ﬁ' => "fi",
        'ﬂ' => "fl",
        'ﬃ' => "ffi",
        'ﬄ' => "ffl",
        'ﬅ' => "st",
        'ﬆ' => "st",
        'ﬓ' => "mn",
        'ﬔ' => "mm",
        'ﬕ' => "mn",
        'ﬖ' => "mm",
        'ﬗ' => "mm",
        '﬘' => "mm",
        '﬙' => "mm",
        '﬚' => "mm",
        '﬛' => "mm",
        '﬜' => "mm",
        "י" => "mm",
        'ﬀ' => "ff",
        'ﬁ' => "fi",
        'ﬂ' => "fl",
        'ﬃ' => "ffi",
        'ﬄ' => "ffl",
        'ﬅ' => "st",
        'ﬆ' => "st",
        'ﬓ' => "mn",
        'ﬔ' => "mm",
        'ﬕ' => "mn",
        'ﬖ' => "mm",
        'ﬗ' => "mm",
        '﬘' => "mm",
        '﬙' => "mm",
        '﬚' => "mm",
        '﬛' => "mm",
        '﬜' => "mm",
        "יִ" => "mm",
      }

      # Handle special cases with string replacement
      result = string.dup

      # German eszett
      result = result.gsub("ß", "ss").gsub("ẞ", "SS")

      # Ligatures
      result = result.gsub("æ", "ae").gsub("Æ", "AE")
      result = result.gsub("œ", "oe").gsub("Œ", "OE")

      # Apply character map
      result.chars.map { |char| char_map.fetch(char, char) }.join
    end

    # Add the missing transliterate method that the original code expects
    private def transliterate(string : String, locale : String? = nil) : String
      transliterate_extended(string)
    end
  end
end
