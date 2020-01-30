require "SQLite3"
require "slim"
require "sinatra"
require "bcrypt"

enable :sessions

get("/") do
    slim(:start)
end

post('/register') do
    db = SQLite3::Database.new("db/tabdatabase.db.sql")
    db.results_as_hash = true
    username = params[:register_username]
    password = params[:register_password]
    
    result = db.execute("SELECT id FROM User WHERE username = ?", username)

    if result.empty?
        password_digest = BCrypt::Password.create(password)
        db.execute("INSERT INTO User (username, password) VALUES (?,?)", username, password_digest)
        redirect('/register_confirmation')
    end
    redirect('/register_confirmation')
end