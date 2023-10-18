# Welcome to My Users App
***

## Task
To implement a famous architecture MVC (Model View Controller) by creating the following three files:
a) my_user_model.rb
b) app.rb
c) indel.erb

## Description
In this project we implement a very famous architecture: MVC (Model View Controller) in order to build an application called My Users APP.
We create three files my_user_model.rb, app.rb and index.erb and their description are as follows:

1) Model -- my_user_model.rb
********************
In this file, we create a class User which is an interface in order to create user, find user, get all users, update user and destroy in sqlite database to manage user data.
We use the gem sqlite3 and the sqlite filename will be named db.sql.
We create a table users with the following attributes:
firstname as string
lastname as string
age as integer
password as string
email as string

The class User contains the following methods:

def create(user_info)
Creates a new user in the users table with the provided information.
Returns the unique ID (a positive integer) of the newly created user.

def find(user_id)
Retrieves the associated user from the users table based on the provided user ID.
Returns all information contained in the database for the specified user.

def all
Retrieves all users from the users table.
Returns a hash containing information about all users.

def update(user_id, attribute, value)
Retrieves the associated user based on the provided user ID.
Updates the specified attribute with the given value.
Returns the user hash after the update.

def destroy(user_id)
Retrieves the associated user based on the provided user ID.
Removes the user from the users table.

Additionally, the table creation logic is encapsulated in the create_table private method, ensuring that the required table structure is in place.

**************************************************************************************************************************************
2) Controller -- app.rb

In this file, we use the User class from the file my_user_model.rb.
It contains multiple routes whic return JSON

GET on /users:
****************
Route: get '/users'
Returns all users (without their passwords) in JSON format.

POST on /users:
******************
Route: post '/users'
Creates a new user in the database and returns the created user (without password) in JSON format.

POST on /sign_in:
********************
Route: post '/sign_in'
Authenticates a user based on the provided email and password.
If successful, adds a session containing the user_id and returns the authenticated user (without password) in JSON format.

PUT on /users:
*******************
Route: put '/users'
Requires a user to be logged in.
Receives a new password and updates it for the logged-in user.
Returns the updated user (without password) in JSON format.

DELETE on /sign_out:
*************************
Route: delete '/sign_out'
Requires a user to be logged in.
Signs out the current user, clearing the session.
Returns nothing (HTTP status code 204).

DELETE on /users:
**************************
Route: delete '/users'
Requires a user to be logged in.
Signs out the current user, destroys the user in the database, and returns nothing (HTTP status code 204).

We use the session and cookies for signed-in method. We use saved cookies in order to perform curl request.
******************************************************************************************************************
3) view -- index.erb
*********************
We create a subdirectory views in which we create a file named index.erb which will be rendered in the route Get on /

Notes: 
 We set the directory views to ./views by defining set('views', './views')
 we use port: 8080 to run the server locally
 We change the binding address to: 0.0.0.0 to access the applicaton from the browser 

## Installation
Install Puma Gem: 
Puma is a web server often used with Sinatra applications
command *** - gem install Puma 

Install connection_pool gem: 
A mechanism for managing and reusing database connecitons. A connection pool is a cache of database connections that are created and kept open, ready to be reused.
Instead of creating a new connection for each request, the application borrows a connection from the pool and returns it when done.
command *** - gem install connection_pool

## Usage

To run the Sinatra application 
command - ruby app.rb

curl command for making a HTTP Post request on /users: ***
1- Params data
 curl -X POST -i https://web-w23a9762c-19b3.docode.us.qwasar.io/users -d "firstname=Neema" -d "lastname=Shrestha" -d "age=16" -d "password=neema16" -d "email=neema@example.com"
**************************************************************************************
2- JSON data
# Define the URL
url="https://web-w23a9762c-19b3.docode.us.qwasar.io/users" 
# Define the request body as a JSON object
requestBody='{
  "firstname": "John",
  "lastname": "Rambo",
  "age": 48,
  "password": "john12rambo",
  "email": "johnrambo@example.com"
}' 
# Define headers
headers="Content-Type: application/json" 
# Make the POST request using curl
response=$(curl -X POST -i -H "$headers" -d "$requestBody" "$url") 
# Display the response headers and body
echo "$response" 
******************************************************************************************
# curl post request on /sign_in route:
curl -X POST -i https://web-w23a9762c-19b3.docode.us.qwasar.io/sign_in -d "password=neema16" -d "email=neema@example.com"

# curl put request on /users route:
curl -X PUT -i https://web-w23a9762c-19b3.docode.us.qwasar.io/users -H "Cookie: rack.session=rdySYqdWgXK4H2jB57kj9MwMOBPcUjDuL7D8qBdGBi7zZRjJTx5WR602gHi%2Fg%2B5wYFr0g1qNI4IQqFBykrIG0tc4CunSCjBtEs5uhk92y079ou6l7eakGGLINOmbR7sewhjEpGOplF6ZPqgwwc%2FKWr2VUDTm%2BJyDqwxGZlC%2FaGi0%2BzS21wndpmuJkPMq%2Bn%2BKWW7gpAKPteTjpyUl4thMzmmrcq9EZ3nCef1MuaCZaSsLZgUhzuhQDrOGGaecciVUIPylt6C79%2FyFeoEEzTQvkmcKmEYy8DLrgFOVBSaNHg%3D%3D--p%2FhkA9TVmUmvM9DV--h4pyEIfouY3CLevXU%2Fx3Fw%3D%3D; path=/; HttpOnly" -d "new_password=naina19"

# curl DELETE request to the /sign_out route
curl -X DELETE -i https://web-w23a9762c-19b3.docode.us.qwasar.io/sign_out -H "Cookie: rack.session=D%2FsvUb%2B69mIWlwAlLHdt5BUZUoulcG51RTvaeHQ74a4PVjWzYlcJLur2e8OAuGEJL%2FxfDxfPRnTdlO0%2FqbFJXnwhi89%2BLbANbHwUQqrYfKHEQPR7rgzqpLdb1tKdP38avJIJqjga1sEmp%2BbREadqwRQknCEz8F1EIFgx7o20RTSQR8XCdHrhnNdR4cyVXBRYk%2FbThg3Q5wst2UohRyMjZ6CkI1W5Mkr6CmY30DVYrpRKtTKYZdDbcLh98qv82LxpZ7Ap93UpYq1Uts%2FdEZQNoB4vfVViQDFltlRQ9%2BpxaA%3D%3D--AQSYsDVnAwgjEuv1--hGS5xLSYrZ9GsGU3dE%2BMjg%3D%3D; path=/; HttpOnly"

# curl command to simulate a DELETE request to the /users route
curl -X DELETE -H "Cookie: session=5" https://web-w23a9762c-19b3.docode.us.qwasar.io/users 



### The Core Team
-- solo -- Prakash Shrestha


<span><i>Made at <a href='https://qwasar.io'>Qwasar SV -- Software Engineering School</a></i></span>
<span><img alt='Qwasar SV -- Software Engineering School's Logo' src='https://storage.googleapis.com/qwasar-public/qwasar-logo_50x50.png' width='20px' /></span>

