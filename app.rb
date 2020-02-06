require "SQLite3"
require "slim"
require "sinatra"
require "bcrypt"

enable :sessions

def set_error(error_message)
    session[:error] = error_message
end

def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end

get("/") do
    slim(:start)
end

post('/register') do
    db = connect_to_db("db/tabdatabase.db")
    username = params[:register_username]
    password = params[:register_password]
    
    result = db.execute("SELECT user_id FROM User WHERE username = ?", username)

    if result.empty?
        password_digest = BCrypt::Password.create(password)
        db.execute("INSERT INTO User (username, password) VALUES (?,?)", username, password_digest)
        redirect('/register_confirmation')
    end
    redirect('/')
end

post('/login') do
    db = connect_to_db('db/tabdatabase.db')
    username = params[:username]
    session[:username] = username
    password = params[:password]
    result = db.execute("SELECT user_id,password FROM User WHERE username = ?", username)
    if result.empty?
        set_error("Invalid username or password")
        redirect('/error')
    end

    user_id = result.first["user_id"]
    password_digest = result.first["password"]
    if BCrypt::Password.new(password_digest) == password
        session[:user_id] = user_id
        redirect('/home_sida')
    else
        set_error("Invalid username or password")
        redirect('/error')
    end
end

#kollar om man är inloggad när man antingen refreshar sidan eller byter path
before do
    if (session[:user_id] == nil) && (request.path_info != '/') && (request.path_info != '/login')
        redirect('/')
    end
end

get('/home_sida') do
    slim(:home_sida)
end

get('/tabs') do
    #lista alla tabs
end

get('/create_tab') do
    #skapa tabs, håll koll på user, sessions?
end

get('/logout') do
    session[:user_id] = nil
    session[:username] = nil
    redirect('/')
end

get('/settings') do 
    slim(:settings)
    #håll koll på user, delete user, change password
end

post('/delete') do
    db = connect_to_db('db/tabdatabase.db')
    db.execute("DELETE * FROM User WHERE user_id = ?", session[:user_id])
    redirect('/')
end

get('/error') do
    slim(:error)
end