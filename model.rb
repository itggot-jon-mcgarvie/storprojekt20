def set_error(error_message)
    session[:error] = error_message
end

def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end

def cooldown()
    # i dont know
end

#kollar om man är inloggad när man antingen refreshar sidan eller byter path
def check_logged_in()
    if session[:user_id] == nil
        slim(:"login/start")
    end
end