def set_db()
    db = SQLite3::Database.new('db/tabdatabase.db')
    db.results_as_hash = true
    return db
end

def set_error(error_message)
    session[:error] = error_message
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

def register_user(username, password_digest)
    db = set_db()
    db.execute("INSERT INTO User (username, password) VALUES (?,?)", username, password_digest)
end

def delete_user(id)
    db = set_db()
    db.execute("DELETE FROM User WHERE user_id = ?", id)
end

def update_user(old_password, id)
    db = set_db()
    compare_password = db.execute("SELECT password FROM User WHERE user_id = ?", id)
    new_password = BCrypt::Password.create(params[:new])
    if BCrypt::Password.new(compare_password.first["password"]) == old_password
        db.execute("UPDATE User SET password=? WHERE user_id=?",new_password,id)
    else
        error_message = "Passwords don't match"
        return error_message
    end
end

def get_user(username)
    db = set_db()
    db.execute("SELECT * FROM User WHERE username = ?", username)
end

def get_tabs_for_user(id)
    db = set_db()
    db.execute("SELECT * FROM Tab WHERE created_by = ?", id)
end

def get_all_tabs()
    db = set_db()
    db.execute("SELECT * FROM Tab")
end

def find_artist_id(artist)
    db = set_db()
    artist_id = db.execute("SELECT artist_id FROM Artist WHERE name = ?", artist)
    if artist_id.empty?
        db.execute("INSERT INTO Artist (name) VALUES (?)", artist)
        artist_id = db.execute("SELECT artist_id FROM Artist WHERE name = ?", artist)
    end
    artist_id = (artist_id.first)["artist_id"]
end

def register_tab(content,title,artist_id,created_on,created_by)
    db = set_db()
    db.execute("INSERT INTO Tab (content, title, artist_id, created_on, created_by) VALUES (?,?,?,?,?)", content, title, artist_id, created_on, created_by)
    tab_id = db.execute("SELECT MAX(tab_id) AS this_tab FROM Tab").first["this_tab"]
    db.execute("INSERT INTO tab_artist_relation (tab_id, artist_id) VALUES (?,?)", tab_id, artist_id)
    return tab_id
end

def get_artist(id)
    db = set_db()
    artist = db.execute("SELECT Artist.name FROM tab_artist_relation INNER JOIN Artist ON tab_artist_relation.artist_id = Artist.artist_id WHERE tab_id = ?", id)
end

def get_a_tab(id)
    db = set_db()
    result = db.execute("SELECT * FROM Tab WHERE tab_id = ?", id)
end

def get_username(id)
    db = set_db()
    user_id = db.execute("SELECT created_by FROM Tab WHERE tab_id = ?", id)
    user = db.execute("SELECT username FROM User WHERE user_id=?", user_id.first[0])
end

def delete_tab(id)
    db = set_db()
    db.execute("DELETE FROM Tab WHERE tab_id = ?", id)
    db.execute("DELETE FROM tab_artist_relation WHERE tab_id = ?", id)
end

def update_tab(new_title, new_content, id)
    db = set_db()
    db.execute("UPDATE Tab SET title = ?, content = ? WHERE tab_id = ?", new_title, new_content, id)
end
#ta bort sessions ur denna