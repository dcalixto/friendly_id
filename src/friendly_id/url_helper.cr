module FriendlyId
  module UrlHelper
    def friendly_path(record)
      record.slug || record.id
    end
  end
end
