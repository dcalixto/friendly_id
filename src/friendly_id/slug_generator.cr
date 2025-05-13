module FriendlyId
  module SlugGenerator
    extend self

    def parameterize(string : String, separator : String = "-", preserve_case : Bool = false, locale : String? = nil) : String
      # Check if the string contains non-Latin characters
      if contains_cjk?(string)
        return parameterize_cjk(string, separator)
      end

      # Start with transliteration for ASCII equivalents
      parameterized_string = transliterate(string, locale)

      # Handle separator patterns
      re_duplicate_separator = separator == "-" ? /-{2,}/ : /#{Regex.escape(separator)}{2,}/

      re_leading_trailing_separator = separator == "-" ? /^-|-$/i : /^#{Regex.escape(separator)}|#{Regex.escape(separator)}$/i

      # Process the string
      parameterized_string = parameterized_string
        .gsub(/[^a-z0-9\-_]+/i, separator)
        .gsub(re_duplicate_separator, separator)
        .gsub(re_leading_trailing_separator, "")

      preserve_case ? parameterized_string : parameterized_string.downcase
    end

    # New method to handle CJK (Chinese, Japanese, Korean) and other non-Latin text
    def parameterize_cjk(string : String, separator : String = "-") : String
      # First try to extract any Latin characters for a readable slug
      latin_only = string.gsub(/[^\p{Latin}\p{N}\s-]/, "").strip

      if !latin_only.empty?
        # If we have Latin characters, use them for the slug
        return parameterize(latin_only, separator)
      else
        # For non-Latin text (like Chinese, Japanese, etc.)
        # Use Base64 encoding to create a URL-safe representation
        encoded = Base64.strict_encode(string.to_slice)
          .gsub("+", "-")
          .gsub("/", "_")
          .gsub("=", "")

        # Limit length and add prefix to indicate encoding
        "cjk-#{encoded[0..40]}"
      end
    end

    # Helper method to detect CJK characters
    def contains_cjk?(string : String) : Bool
      # Check for Chinese, Japanese, Korean characters
      # Unicode ranges for CJK:
      # - CJK Unified Ideographs: U+4E00-U+9FFF
      # - Hiragana: U+3040-U+309F
      # - Katakana: U+30A0-U+30FF
      # - Hangul Syllables: U+AC00-U+D7AF
      string.each_char do |char|
        code_point = char.ord
        if (0x4E00 <= code_point && code_point <= 0x9FFF) || # CJK Unified Ideographs
           (0x3040 <= code_point && code_point <= 0x309F) || # Hiragana
           (0x30A0 <= code_point && code_point <= 0x30FF) || # Katakana
           (0xAC00 <= code_point && code_point <= 0xD7AF)    # Hangul
          return true
        end
      end
      false
    end

    private def transliterate(string : String, locale : String? = nil) : String
      # Basic transliteration map - expand as needed
      string.gsub(/[àáâãäåāăąạảấầẩẫậắằẳẵặ]/, "a")
        .gsub(/[èéêëēĕėęěẹẻẽếềểễệ]/, "e")
        .gsub(/[ìíîïĩīĭįỉịớờởỡợớờởỡợ]/, "i")
        .gsub(/[òóôõöōŏőơọỏốồổỗộớờởỡợ]/, "o")
        .gsub(/[ùúûüũūŭůųưụủứừửữự]/, "u")
        .gsub(/[ýÿỳỵỷỹ]/, "y")
        .gsub(/[ñń]/, "n")
        .gsub(/[çćĉċč]/, "c")
        .gsub(/[żźž]/, "z")
        .gsub(/[śŝşš]/, "s")
    end
  end
end
