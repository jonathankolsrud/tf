require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
    if nil == session[:id]
        redirect('/register')
    else
        slim(:bodymaker)
    end
end

get('/register') do
    slim(:register)
end

get('/bodymaker') do
    if nil == session[:id]
        redirect('/showlogin')
    end
    slim(:bodymaker)
end

post('/bodymaker') do
    id = session[:id]
    height = params[:height]
    weight = params[:weight]
    db = SQLite3::Database.new("db/db.db")
    height_id = db.execute("SELECT id FROM heights WHERE height = ?", height).first.first
    weight_id = db.execute("SELECT id FROM weights WHERE weight = ?", weight).first.first
    session[:size] = db.execute("SELECT size FROM heightweightsize WHERE height = ? AND weight = ?", height_id, weight_id).first.first
    redirect('/sizedone')
end

get('/sizedone') do
    slim(:sizedone)
end

post('/sizedone') do
    bodyname = params[:bodyname]
    user_id = session[:id].to_i
    topsize = session[:size]
    bottomsize = session[:size]
    db = SQLite3::Database.new("db/db.db")
    db.execute('INSERT INTO bodies (bodyname,user_id,topsize,bottomsize) VALUES (?,?,?,?)',bodyname,user_id,topsize,bottomsize)
    redirect('/bodies')
end

get('/bodies') do
    id = session[:id].to_i
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM bodies WHERE user_id = ?",id)
    p "Alla bodies från result lol #{result}"
    slim(:"/bodies",locals:{bodies:result})
end  

post('/deletebody') do
    delete = params[:delete]
    p delete
end



get('/showlogin') do
    slim(:login)
end  

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirmed = params[:password_confirmed]
  
    if (password == password_confirmed)
      #lägg till användare
      password_digest = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/db.db')
      db.execute('INSERT INTO users (username,pwdigest) VALUES (?,?)',username,password_digest)
      redirect('/bodymaker')
  
    else
      #felhantering
      "lösenorden matchade inte"
    end
end

post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwdigest = result["pwdigest"]
    id = result["id"]
    if BCrypt::Password.new(pwdigest) == password
        session[:id] = id
        session[:username] = username
        redirect('/bodymaker')
        
    else
        "FEL LÖSEN HAHA!"
    end
end

get('/logout') do
    session[:id] = nil
    session[:username] = nil
    redirect('/register')
end