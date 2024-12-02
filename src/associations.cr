module FriendlyId
  macro has_many(declaration, foreign_key)
    def {{declaration.var}}
      {{declaration.type}}.where({{foreign_key}}: id)
    end
  end
end
