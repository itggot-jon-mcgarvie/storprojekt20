require "SQLite3"
require "slim"
require "sinatra"
require "bcrypt"
require "byebug"
require_relative "model.rb"

enable :sessions

get("/") do
    slim(:"login/start")
end

post('/register') do
    db = connect_to_db("db/tabdatabase.db")
    username = params[:register_username]
    password = params[:register_password]
    
    result = db.execute("SELECT * FROM User WHERE username = ?", username)
    
    if result.empty?
        password_digest = BCrypt::Password.create(password)
        db.execute("INSERT INTO User (username, password) VALUES (?,?)", username, password_digest)
        redirect('/')
    else
        set_error("That username is already in use")
        redirect('/error')
    end
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
# cooldown
    user_id = result.first["user_id"]
    password_digest = result.first["password"]
    t = Time.now
    t2 = t + 10*60
    if Time.now == t2
        session[:login_allowed] = true
        
    end
    
    # if cooldown < 50 && session[:login_allowed] = true
        if BCrypt::Password.new(password_digest) == password
            session[:user_id] = user_id
            redirect('/home_sida')
        else
            set_error("Invalid username or password")
            redirect('/error')
            # cooldown++
        end
    # else
    #     session[:login_allowed] = false
    # end
    
end

#kollar om man är inloggad när man antingen refreshar sidan eller byter path
# after('/login') do
#     if (session[:user_id] == nil) && (request.path_info != '/')
#         redirect('/logout')
#     end
# end

get('/home_sida') do
    slim(:"tabs/home_sida")
end

get('/tabs') do
    #lista länkar till alla tabs
    db = connect_to_db('db/tabdatabase.db')
    result_user = db.execute("SELECT * FROM Tab WHERE created_by = ?", session[:username])
    result_all = db.execute("SELECT * FROM Tab")
    slim(:"tabs/show_tab_links", locals:{result:result_all, user:result_user})
end

get('/show_tab/:id') do
    db = connect_to_db('db/tabdatabase.db')
    id = params[:id]
    result = db.execute("SELECT * FROM Tab WHERE tab_id = ?", id)
    user_id = db.execute("SELECT created_by FROM Tab WHERE tab_id = ?", id)
    # p user_id
    # user = db.execute("SELECT username FROM User WHERE user_id = ?", user_id)
    slim(:"tabs/show_tab", locals:{result:result})
end

get('/create_tab') do
    #skapa tabs, håll koll på user, sessions?
    #tab_id, content, title, artist, created_on, created_by
    slim(:"tabs/create_tab")
end

post('/register_tab') do
    db = connect_to_db('db/tabdatabase.db')
    content = params[:content]
    title = params[:title]
    artist = params[:artist]
    time = Time.now
    created_on = time.inspect
    created_by = session[:username]
    db.execute("INSERT INTO Tab (content, title, artist_id, created_on, created_by) VALUES (?,?,?,?,?)", content, title, artist, created_on, created_by)
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