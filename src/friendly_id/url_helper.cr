module FriendlyId
  module UrlHelper
    def friendly_path(record : T) forall T
      return unless record
      record.slug || record.id
    end
  end
end
