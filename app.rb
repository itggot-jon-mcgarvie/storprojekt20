require "SQLite3"
require "slim"
require "sinatra"
require "bcrypt"

enable :sessions

def set_error(error_message)
    session[:error] = error_message
end

get("/") do
    slim(:start)
end

post('/register') do
    db = SQLite3::Database.new("db/tabdatabase.db")
    db.results_as_hash = true
    username = params[:register_username]
    password = params[:register_password]
    
    result = db.execute("SELECT user_id FROM User WHERE username = ?", username)

    if result.empty?
        password_digest = BCrypt::Password.create(password)
        db.execute("INSERT INTO User (username, password) VALUES (?,?)", username, password_digest)
        redirect('/register_confirmation')
    end
    redirect('/register_confirmation')
end

get('/register_confirmation') do
    db = SQLite3::Database.new('db/tabdatabase.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM User")
    slim(:register_confirmation, locals:{result:result})
end

post('/login') do
    
    username = params[:username]
    session[:username] = username
    password = params[:password]
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    result = db.execute("SELECT user_id,password FROM User WHERE username = ?", username)
    if result.empty?
        set_error("Invalid username or password")
        redirect('/error')
    end

    user_id = result.first["id"]
    password_digest = result.first["password_digest"]
    if BCrypt::Password.new(password_digest) == password
        session[:user_id] = user_id
        redirect('/login_sida')
    else
        set_error("Invalid username or password")
        redirect('/error')
    end
end

get('/error') do
    slim(:error)
end