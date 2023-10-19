require 'sqlite3'
require 'connection_pool' 
require 'logger'

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

    LOG_fILE = 'My_user_model.log'
    LOGGER = Logger.new(LOG_fILE)

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
        begin 
            # to check if the required fields are not empty 
            validate_user_information(user_information)             

            @db.with do |connection|
                connection.execute(
                    "INSERT INTO users (firstname, lastname, age, password, email) VALUES (:firstname, :lastname, :age, :password, :email)",
                    user_information
                ) 
                # created_user as a hash with the required keys
                created_user = {
                    'id' => connection.last_insert_row_id, 
                    'firstname' => user_information['firstname'],
                    'lastname' => user_information['lastname'], 
                    'age' => user_information['age'], 
                    'email' => user_information['email']
                }
                # to return the created_user hash 
                created_user
            end 
        # if any exception is raised in the begin block, the exception object with assigned to variable 'e'
        rescue ArgumentError => e 
            {error: e.message}
        rescue SQLite3::Exception => e 
            # calls a private method handle_database_error
            handle_database_error(e, "Failed to create user. Please check your input")
        rescue  StandardError => e 
            # to handle any other standard errors which are not specified to SQLite. It prints a generic error message about th exception
            LOGGER.error("An unexpected error occured: #{e.message}")
            {error: "Unexpected error"}
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
    # public 
    def all
        @db.with do |connection|
            connection.results_as_hash = true
            result = connection.execute("SELECT id, firstname, lastname, age, email FROM users") 
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

    
    private 
    
    def validate_user_information(user_information) 
        if user_information['firstname'].to_s.strip.empty? || user_information['lastname'].to_s.strip.empty? || user_information['email'].to_s.strip.empty? || user_information['password'].to_s.strip.empty?
            raise ArgumentError, 'firstname, lastname, email and password are required'
        end 
    end  

    def handle_database_error(exception, custom_message = nil) 
        # to display custom message if provided, otherwise generic message
        error_message = custom_message || "Database Interaction Error: #{exception.message}" 

        # to log the error message 
        LOGGER.error(error_message)

        # to return an error hash with the error message 
        {error: error_message}
    end 

end
        

