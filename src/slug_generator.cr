module SlugGenerator
  extend self
  def parameterize(string : String, separator : String = "-", preserve_case : Bool = false, locale : String? = nil) : String
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
