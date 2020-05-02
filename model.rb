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
def check_logged_in(path)
    if session[:user_id] == nil
        slim(:"login/start")
    else
        slim(path)
    end
end

def register_user(db, username, password_digest)
    db.execute("INSERT INTO User (username, password) VALUES (?,?)", username, password_digest)
end

def get_user(db, username)
    db.execute("SELECT * FROM User WHERE username = ?", username)
end

def get_tabs_for_user(db, id)
    db.execute("SELECT * FROM Tab WHERE created_by = ?", id)
end

def get_all_tabs(db)
    db.execute("SELECT * FROM Tab")
end

def new_post()

end

def edit_post()

end

def get_a_post()

end

def delete_post()

end
#ta bort sessions ur denna