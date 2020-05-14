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

def get_artist(db, id)
    artist = db.execute("SELECT Artist.name FROM tab_artist_relation INNER JOIN Artist ON tab_artist_relation.artist_id = Artist.artist_id WHERE tab_id = ?", id)
end

def get_a_tab(db, id)
    result = db.execute("SELECT * FROM Tab WHERE tab_id = ?", id)
end

def get_username(db, id)
    user_id = db.execute("SELECT created_by FROM Tab WHERE tab_id = ?", id)
    user = db.execute("SELECT username FROM User WHERE user_id=?", user_id.first[0])
end

def delete_tab(db, id)
    db.execute("DELETE FROM Tab WHERE tab_id = ?", id)
    db.execute("DELETE FROM tab_artist_relation WHERE tab_id = ?", id)
end
#ta bort sessions ur denna