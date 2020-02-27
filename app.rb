require "SQLite3"
require "slim"
require "sinatra"
require "bcrypt"
require "byebug"
require_relative "model.rb"

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
        redirect('/')
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
# after('/login') do
#     if (session[:user_id] == nil) && (request.path_info != '/')
#         redirect('/logout')
#     end
# end

get('/home_sida') do
    slim(:home_sida)
end

get('/tabs') do
    #lista länkar till alla tabs
    db = connect_to_db('db/tabdatabase.db')
    result = db.execute("SELECT * FROM Tab")
    slim(:show_tab_links, locals:{result:result})
end

get('/show_tab/:id') do
    db = connect_to_db('db/tabdatabase.db')
    # title = db.execute("SELECT title FROM Tab WHERE tab_id = ?", :id)
    # content = db.execute("SELECT content FROM Tab WHERE tab_id = ?", :id)
    # artist = db.execute("SELECT artist FROM Tab WHERE tab_id = ?", :id)
    result = db.execute("SELECT * FROM Tab WHERE tab_id = ?", :id)
    slim(:show_tab, locals:{result:result})
end

get('/create_tab') do
    #skapa tabs, håll koll på user, sessions?
    #tab_id, content, title, artist, created_on, created_by
    slim(:create_tab)
end

post('/register_tab') do
    db = connect_to_db('db/tabdatabase.db')
    content = params[:content]
    title = params[:title]
    artist = params[:artist]
    time = Time.now
    created_on = time.inspect
    created_by = session[:user_id]
    db.execute("INSERT INTO Tab (content, title, artist, created_on, created_by) VALUES (?,?,?,?,?)", content, title, artist, created_on, created_by)
    redirect('/home_sida')
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
    db.execute("DELETE FROM User WHERE user_id = ?", session[:user_id])
    redirect('/logout')
end

post('/update') do
    db = connect_to_db('db/tabdatabase.db')
    old_password = params[:old]
    compare_password = db.execute("SELECT password FROM User WHERE user_id = ?", session[:user_id])
    new_password = BCrypt::Password.create(params[:new])
    if BCrypt::Password.new(compare_password.first["password"]) == old_password
        db.execute("UPDATE User SET password=? WHERE user_id=?",new_password,session[:user_id])
    end
    
    redirect('/settings')
end

get('/error') do
    slim(:error)
end