class User < FriendlyId::BaseModel
  include FriendlyId::HasMany

  has_many :posts

  property id : Int64?
  property name : String

  def initialize(@name : String)
  end

  def save
    TestDB.database.exec "INSERT INTO users (name) VALUES (?)", @name
    @id = TestDB.database.scalar("SELECT last_insert_rowid()").as(Int64)
  end

  def self.create!(name : String) : User
    user = new(name)
    user.save
    user
  end

  def self.where(user_id : Int64)
    results = [] of User
    TestDB.database.query("SELECT * FROM users WHERE id = ?", user_id) do |rs|
      rs.each do
        results << new(
          rs.read(String)
        )
      end
    end
    results
  end
end
