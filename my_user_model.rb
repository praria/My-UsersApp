# SQLite is a C library that provides a lightweight, disk-based database.
# sqlite3 gem is the sqlite database driver which facilites the integration of sqlite database with ruby applications 
# sqlite3 gem provides SQLite3::Database class for database connection
require 'sqlite3'

# connection_pool gems provides the connectionpool class that manages the limited number of SQLite database conncetions
require 'connection_pool'

# defining a User class that provides an interface to interacts with sqlite database using basic CRUD operations on user records
# It encapsulates the database operations within methods and uses a connection pool for efficient database connections.
class User
    DATABASE_FILE = 'db.sql'
    MAXIMUM_CONNECTIONS = 5
    # The following block gets executed when a new connection is needed. 
    # It creates a new instance of SQLite3::Database class using the SQLite database file specified by DataBase_FILE.
    # creates a connection pool("DATABASE_POOL") using the connectionpool gem. It ensures the max of 5 connections to the SQLite database specified by 'db.sql'
    DATABASE_POOL = ConnectionPool.new(size: MAXIMUM_CONNECTIONS, timeout: 5) do
        SQLite3::Database.new(DATABASE_FILE)
    end

    # Initializes a new instance of the User class and Sets the @db instance variable to the connection pool.
    # Calls the create_table private method to ensure that the 'users' table exists in the database.
    def initialize
        @db = DATABASE_POOL
        create_table 
    end 

    # defining a private method create_table that uses the connection pool to execute a SQL command, creating the 'users' table if it doesn't already exist.
    # Here, <<-SQL is the heredoc syntax, and SQL is the identifier marking the end of the string.
    private
    def create_table
        @db.with do |connection|
            connection.execute <<-SQL 
                CREATE TABLE IF NOT EXISTS users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    firstname TEXT,
                    lastname TEXT,
                    age INTEGER,
                    password TEXT,
                    email TEXT
                );
            SQL
        end
    end 

    public 

    # This method inserts the new record/user into the users table. The user_information parameter is a hash containing the new user informations 
    def create(user_information)
        @db.with do |connection|
            connection.execute(
                "INSERT INTO users (firstname, lastname, age, password, email) VALUES (:firstname, :lastname, :age, :password, :email)",
                user_information
            )
            connection.last_insert_row_id
        end
    end

    # retrieves the user information based on id. ".first" is used to retrieve only first matching record
    def find(user_id)
        @db.with do |connection|
            connection.results_as_hash = true 
            connection.execute("SELECT * FROM  users WHERE id = ?", [user_id]).first 
        end 
    end 

    def find_by_email(email)
        @db.with do |connection|
            connection.execute("SELECT * FROM users WHERE email = ?", [email]).first
        end 
    end 

    # retrieve information for all users from the database
    def all
        @db.with do |connection|
            connection.results_as_hash = true
            result = connection.execute("SELECT id, firstname, lastname, age, email FROM users")
            puts result.inspect # adding this line for debugging
            result
        end 
    end 

    # this update method takes a "user_id", an "attribute" to update and the new "value" for that attribute
    # It then construct and executes an SQL UPDATE statement to modify the user's data in the database
    # Finally, it calls a "find" method to retrieve and return the updated user's information
    def update(user_id, attribute, value)
        @db.with do |connection|
            connection.execute("UPDATE users SET #{attribute} = ? WHERE id = ?", [value, user_id])
            find(user_id)
        end 
    end 


    # delete the user with specified id from the users table in the database
    def destroy(user_id) 
        @db.with do |connection|
            connection.execute("DELETE FROM users WHERE id = ?", [user_id])
        end 
    end         

end
        

