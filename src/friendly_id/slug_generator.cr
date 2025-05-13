module FriendlyId
  module SlugGenerator
    extend self

    def parameterize(string : String, separator : String = "-", preserve_case : Bool = false, locale : String? = nil) : String
      # Check if the string contains non-Latin characters
      if contains_non_latin_script?(string)
        return parameterize_non_latin(string, separator)
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

    # New method to handle non-Latin scripts (CJK, Cyrillic, Devanagari, Arabic, etc.)
    def parameterize_non_latin(string : String, separator : String = "-") : String
      # First try to extract any Latin characters for a readable slug
      latin_only = string.gsub(/[^\p{Latin}\p{N}\s-]/, "").strip

      if !latin_only.empty?
        # If we have Latin characters, use them for the slug
        return parameterize(latin_only, separator)
      else
        # For non-Latin text, use Base64 encoding to create a URL-safe representation
        # Add a prefix based on script detection
        prefix = detect_script_prefix(string)

        encoded = Base64.strict_encode(string.to_slice)
          .gsub("+", "-")
          .gsub("/", "_")
          .gsub("=", "")

        # Limit length and add prefix to indicate encoding
        "#{prefix}-#{encoded[0..40]}"
      end
    end

    # Helper method to detect non-Latin scripts
    def contains_non_latin_script?(string : String) : Bool
      string.each_char do |char|
        code_point = char.ord
        # Skip ASCII and Latin characters
        next if code_point < 0x0080 || (0x00C0 <= code_point && code_point <= 0x024F)

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
