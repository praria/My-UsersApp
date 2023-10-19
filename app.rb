require 'sinatra' 
require 'puma'
require 'json' # to load the 'JSON' module
require_relative 'my_user_model'

# enables session support. Sessions are used to store data between request 
enable :sessions

# creates an instance of the User class defined in the my_user_model file
user_model = User.new 

# sets the directory for views(templates) to './views'
set('views', './views') 

# enable logging 
set :logging, true

# run the sinatra app on port 8080 and make it accessible from the browser
set :bind, '0.0.0.0'
set :port, 8080


# defining a route in Sinatra that listens for HTTP GET requests at the '/users' URL path,
# fetches all user data from the database and render the 'index' template.
get '/users' do 
    @users = user_model.all 
    erb :index, locals: {users: @users} 
end 

# for testing purpose
# This route generates a JSON response by excluding the 'password' field from each user's data
get '/users/json' do  
    @users = user_model.all 
    content_type :json  
    JSON.generate(@users.map {|user| user.reject {|key| key == 'password'}}) 
end 



# This route reads and parses the params data/ JSON data from the request body, uses that data to create a new user in the database
# using the user_model, and then returns the newly created user (including the generated ID) as a JSON response to the client
post '/users' do 
    # user_information = JSON.parse(request.body.read)   
    user_information = params
    created_user = user_model.create(user_information) 
    if created_user.is_a?(Hash) && created_user.key?('id') && created_user.key?('firstname') && created_user.key?('lastname') && created_user.key?('email')  
        {message: "User with ID #{created_user['id']} added successfully", name: "#{created_user['firstname']} #{created_user['lastname']}" }.to_json 
    else 
        status 400
        {error: 'firstname, lastname, email and password are required'}.to_json
    end 
end

# This route authenticates a user based on provided credentials, sets a session variable if successful, and returns the user data (exclusind password field)
post '/sign_in' do
    # user_information = JSON.parse(request.body.read)
    user_information = params
    # to validate input
    if user_information['email'].to_s.empty? || user_information['password'].to_s.empty?
        # bad request
        status 400 
        return {error: 'Both email and password are required'}.to_json 
    end 

    user = user_model.find_by_email(user_information['email'])

    if user && user['password'] == user_information['password']
        # Authenticate the user and set a session variable to indicate the user is logged in
        session[:user_id] = user['id']

        # remove the 'password' field from the user data before returning it.
        user.reject! { |key| key == 'password'}
        {message: 'Successfully signed in', user_data: user}.to_json
    else
        status 401 # unauthorized if login fails
        {error: 'Invalid email or password'}.to_json
    end
end

# This Sinatra route updates the password of the currently logged-in user based on the session variable and the new password provided in the request body
put '/users' do
    # check if the user is logged in based on the session variable
    if session[:user_id]
        user_id = session[:user_id] # use the user_id from the session
        attribute = 'password' # always updates the password
        # request_body = JSON.parse(request.body.read)
        request_body = params 
        new_password = request_body['new_password'] # 'new_password is the field name for the new password'

        
        # user_model.update(user_id, attribute, new_password) updates the user's password in the database
        updated_user = user_model.update(user_id, attribute, new_password)

        if updated_user
            # remove the 'password' field from the user data before returning it
            updated_user.reject! {|key| key == 'password'}
            updated_user.to_json
        else
            status 500 # returns status 500 for internal server error
        end
    else
        status 401 # Unathorized if the user is not logged in
    end
end 

# This Sinatra route updates the firstname of the currently logged-in user based on the session variable in the request body 
put '/update_firstname' do 
    # check if the user is logged-in based on the session variable 
    if session[:user_id] 
        user_id = session[:user_id] 
        attribute = 'firstname' # always updates the firstname 
                
        # request_body = JSON.parse(request.body.read)
        request_body = params 
        new_firstname = request_body['new_firstname'].to_s.strip
        if new_firstname.empty?
            status 400 
            return {error: 'New firstname is required'}.to_json 
        end 
        
        # user_model.update(user_id, attribute, new_firstname) updates the user's firstname in the database
        updated_user = user_model.update(user_id, attribute, new_firstname) 
        if updated_user
            # remove sensitive information before returning the updated user data
            updated_user.reject! {|key| key == 'password'}
            updated_user.to_json
        else
            status 500 # returns status 500 for internal server error
        end
    else
        status 401 # Unathorized if the user is not logged in
    end
end 



# Sign-out route clear the session and signout the user
delete '/sign_out' do
    # check if the user is logged in based on the session variable
    if session[:user_id]
        # sign out the current user by clearing the session
        session.clear
        status 204 # No content (successful sign-out)
    else
        status 401 # unathorized if the user is not logged in
    end
end

# sign-out and destroy user route
delete '/users' do
    # check if the user is logged in based on the session variable
    if session[:user_id]
        user_id = session[:user_id]

        # assuming user_model.destroy(user_id) removes the user from the database
        user_model.destroy(user_id)

        # sign out the current user by clearing the session
        session.clear
        status 204 # No content (successful sign-out and user destruction)
    else
        status 401 # unathorized if the user is not logged in
    end
end 

error do 
    status 500 
    {error: env['sinatra.error'].message}.to_json 
end 




