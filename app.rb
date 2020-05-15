require "SQLite3"
require "slim"
require "sinatra"
require "bcrypt"
require "byebug"
require_relative "model.rb"

enable :sessions

get("/") do
    check_logged_in(:home_sida)
end

post('/register') do
    
    username = params[:register_username]
    password = params[:register_password]
    
    result = get_user(username)
    
    if result.empty?
        password_digest = BCrypt::Password.create(password)
        register_user(username, password_digest)
        redirect('/')
    else
        set_error("That username is already in use")
        redirect('/error')
    end
end

post('/login') do
    username = params[:username]
    session[:username] = username
    password = params[:password]
    result = get_user(username)
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
            redirect('/')
        else
            set_error("Invalid username or password")
            redirect('/error')
            # cooldown++
        end
    # else
    #     session[:login_allowed] = false
    # end
    
end

get('/tabs') do
    #lista länkar till alla tabs
    if session[:user_id] != nil
        result_user =  get_tabs_for_user(session[:user_id])
    else
        result_user = "Log in to see your tabs"
    end
    result_all = get_all_tabs()
    slim(:"tabs/index", locals:{result:result_all, user:result_user})
end

get('/tabs/:id') do
    id = params[:id].to_i
    artist = get_artist(id)
    result = get_a_tab(id)
    user = get_username(id)
    slim(:"tabs/show", locals:{result:result, artist:artist, user:user})
end

get('/tabs/:id/edit') do
    result = get_a_tab(params[:id].to_i)
    slim(:"tabs/edit", locals:{result:result.first})
end

post('/tabs/:id/edited') do
    new_title = params[:title]
    new_content = params[:content]
    id = params[:id]
    update_tab(new_title, new_content, id)
    redirect('/tabs/'+ id)
end

get('/tabs/:id/delete') do
    id = params[:id].to_i
    delete_tab(id)
    redirect('/tabs')
end

get('/create_tab') do
    check_logged_in(:"tabs/create")
    #skapa tabs, håll koll på user, sessions?
    #tab_id, content, title, artist, created_on, created_by
end

post('/register_tab') do
    content = params[:content]
    title = params[:title]
    artist = params[:artist]
    time = Time.now
    created_on = time.inspect
    created_by = session[:user_id]
    artist_id = find_artist_id(artist)
    tab_id = register_tab(content,title,artist_id,created_on,created_by).to_s
    # redirecta till taben som skapades
    redirect('/tabs/' + tab_id)
end

get('/logout') do
    session[:user_id] = nil
    session[:username] = nil
    redirect('/')
end

get('/settings') do 
    check_logged_in(:"login/settings")
    #håll koll på user, delete user, change password
end

post('/delete') do
    user_id = session[:user_id]
    delete_user(user_id)
    redirect('/logout')
end

post('/update') do
    old_password = params[:old]
    user_id = session[:user_id]
    session[:error] = update_user(old_password, user_id)
    if session[:error].empty?
        redirect('/settings')
    end
    redirect('/error')
end

get('/error') do
    slim(:error)
end