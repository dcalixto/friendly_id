module FriendlyId
  module HasMany
    macro has_many(association)
        def {{association.id}}
          {{association.id.stringify.gsub(/s$/, "").camelcase.id}}.where(user_id: id.not_nil!)
        end
      end
  end
end
