# Sets database to tabdatabase.db
#
# @return SQLite3 Database
def set_db()
    db = SQLite3::Database.new('db/tabdatabase.db')
    db.results_as_hash = true
    return db
end

# Sets an error message to display
#
# session[:error] The error message
def set_error(error_message)
    session[:error] = error_message
end


def cooldown()
    # i dont know
end

# Checks if the user is logged in and if the page requires the user to be logged in it launches the login page
#
# @param [String] path, What path to return to if true 
def check_logged_in(id)
    if id == nil
        return false
    else
        return true
    end
end

# Creates an account in the database
#
# @param [String] username, The users username
#
# @param [String] password_digest, The users encrypted password
def register_user(username, password_digest)
    db = set_db()
    db.execute("INSERT INTO User (username, password) VALUES (?,?)", username, password_digest)
end

# Deletes the account from the database
#
# @param [Integer] id, The users id
def delete_user(id)
    db = set_db()
    result = db.execute("SELECT tab_id FROM Tab WHERE created_by = ?", id)
    result.each do |item|
        delete_tab(item["tab_id"].to_i)
    end
    db.execute("DELETE FROM User WHERE user_id = ?", id)
end

# Updates the account details in the database
#
# @param [String] old_password, The old password that gets compared to the new one
#
# @param [Integer] id, The users id
#
# @return [String] error_message, The error message to use if the passwords don't match
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

# Acquires the current users account details
#
# @param [String] username, The users username
def get_user(username)
    db = set_db()
    db.execute("SELECT * FROM User WHERE username = ?", username)
end

# Gets all the tabs that were created by the current user
#
# @param [Integer] id, The users id
def get_tabs_for_user(id)
    db = set_db()
    db.execute("SELECT * FROM Tab WHERE created_by = ?", id)
end

# Gets all the tabs stored in the database
def get_all_tabs()
    db = set_db()
    db.execute("SELECT * FROM Tab")
end

# Gets the artists id, if there isn't one, a new artist is created in the database
#
# @param [String] artist, The artist that was submitted in the form
#
# @return [Integer] artist_id, The artists id
def find_artist_id(artist)
    db = set_db()
    artist_id = db.execute("SELECT artist_id FROM Artist WHERE name = ?", artist)
    if artist_id.empty?
        db.execute("INSERT INTO Artist (name) VALUES (?)", artist)
        artist_id = db.execute("SELECT artist_id FROM Artist WHERE name = ?", artist)
    end
    artist_id = (artist_id.first)["artist_id"]
    return artist_id
end

# Registers the tab in to the database
#
# @param [String] content, The content of the tab
#
# @param [String] title, The title of the tab
#
# @param [Integer] artist_id, The id of the artist
#
# @param [String] created_on, The time at which the tab was created
#
# @param [Integer] created_by, The id of the user who created the tab
#
# @return [Integer] tab_id, The id of the created tab
def register_tab(content,title,artist_id,created_on,created_by)
    db = set_db()
    db.execute("INSERT INTO Tab (content, title, artist_id, created_on, created_by) VALUES (?,?,?,?,?)", content, title, artist_id, created_on, created_by)
    tab_id = db.execute("SELECT MAX(tab_id) AS this_tab FROM Tab").first["this_tab"]
    db.execute("INSERT INTO tab_artist_relation (tab_id, artist_id) VALUES (?,?)", tab_id, artist_id)
    return tab_id
end

# Gets the artist name off of the id
#
# @param [Integer] id, The id of the artist
#
# @return [Hash] artist, The name of the artist
def get_artist(id)
    db = set_db()
    artist = db.execute("SELECT Artist.name FROM tab_artist_relation INNER JOIN Artist ON tab_artist_relation.artist_id = Artist.artist_id WHERE tab_id = ?", id)
    return artist
end

# Gets the information of a specific tab
#
# @param [Integer] id, The id of the tab
#
# @return [Hash] result, The information of the tab
def get_a_tab(id)
    db = set_db()
    result = db.execute("SELECT * FROM Tab WHERE tab_id = ?", id)
    return result
end

# Gets the username for the author of the tab
#
# @param [Integer] id, The id of the tab
#
# @return [Hash] user_result, Hash containing more hashes which have the username and user_id of the author of the tab
def get_username(id)
    db = set_db()
    user_id = db.execute("SELECT created_by FROM Tab WHERE tab_id = ?", id)
    user = db.execute("SELECT username FROM User WHERE user_id=?", user_id.first[0])
    user_result = {"user" => user, "user_id" => user_id}
    return user_result
end

# Deletes the tab from the database
#
# @param [Integer] id, The id of the tab
def delete_tab(id)
    db = set_db()
    db.execute("DELETE FROM Tab WHERE tab_id = ?", id)
    db.execute("DELETE FROM tab_artist_relation WHERE tab_id = ?", id)
end

# Updates the title and/or the content of the tab
#
# @param [String] new_title, What the new title should be
#
# @param [String] new_content, What the new content should be
#
# @param [Integer] id, The id of the tab
def update_tab(new_title, new_content, id)
    db = set_db()
    if new_title != ""
        db.execute("UPDATE Tab SET title = ? WHERE tab_id = ?", new_title, id)
    end
    if new_content != ""
        db.execute("UPDATE Tab SET content = ? WHERE tab_id = ?", new_content, id)
    end
end