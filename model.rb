def set_error(error_message)
    session[:error] = error_message
end

def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end