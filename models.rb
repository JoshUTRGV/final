require 'data_mapper' # metagem, requires common plugins too.

# need install dm-sqlite-adapter
# if on heroku, use Postgres database
# if not use sqlite3 database I gave you
if ENV['DATABASE_URL']
  DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
else
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/app.db")
end

class User ###################################### USER
    include DataMapper::Resource
    property :id, Serial
    property :email, String
    property :created_at, DateTime

    # updateable
    property :password, String
    property :first_name, String
    property :last_name, String
    property :username, String
    property :phone, String

    property :rented_out, Integer
    property :pro, Boolean, :default => false

    def login(password)
        return self.password == password
    end
end

class Messege ##################################### Messege
    include DataMapper::Resource
    property :id, Serial
    property :to_id, Integer
    property :from_id, Integer
    property :reason, String
    property :statment, String

    def from_who
        if from_id.nil?
        else
            @P = User.first(e.id == self.from_ID)
            return @P.first_name + " " + @P.last_name
        end
    end

    def to_who
        @P = User.first(e.id == self.to_ID)
        return @P.first_name + " " + @P.last_name
    end
end

class Item ############################################ Item
    include DataMapper::Resource

    property :id, Serial
    property :name, String
    property :description, String

    property :owner_id, Integer

    property :cost_Day, Integer
    property :cost_Week, Integer
    property :available, Boolean,  :default => true
end

class Transaction ################################## TRANSACTION
    include DataMapper::Resource
    property :id, Serial
    property :owner_id, Integer
    property :renters_id, Integer
    property :item_id, Integer

    property :created_at, DateTime
    property :owner_confirmation, Integer, :default => 0
    property :renter_confirmation, Integer, :default => 0

end

# Perform basic sanity checks and iniFtialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the post table
Item.auto_upgrade!
User.auto_upgrade!
Messege.auto_upgrade!
Transaction.auto_upgrade!
