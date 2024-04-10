#User
def no_login()
    if nil == session[:id]
        redirect('/showlogin')
    end
end

def register(username, password, password_confirmed)
    if (password == password_confirmed)
        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new('db/db.db')
        db.execute('INSERT INTO users (username,pwdigest) VALUES (?,?)',username,password_digest)
        redirect('/bodymaker')
    else
        "lösenorden matchade inte"
    end
end

def login(username, password)
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


#Size
def get_size(height, weight)
    db = SQLite3::Database.new("db/db.db")
    height_id = db.execute("SELECT id FROM heights WHERE height = ?", height).first.first
    weight_id = db.execute("SELECT id FROM weights WHERE weight = ?", weight).first.first
    session[:size] = db.execute("SELECT size FROM heightweightsize WHERE height = ? AND weight = ?", height_id, weight_id).first.first
    session[:height] = height
    session[:weight] = weight
end

#Bodies
def save_body(bodyname)
    user_id = session[:id].to_i
    topsize = session[:size]
    bottomsize = session[:size]
    height = session[:height]
    weight = session[:weight] 
    db = SQLite3::Database.new("db/db.db")
    db.execute('INSERT INTO bodies (bodyname,user_id,topsize,bottomsize,height,weight) VALUES (?,?,?,?,?,?)',bodyname,user_id,topsize,bottomsize,height,weight)
end

def delete_body(body_id)
    db = SQLite3::Database.new('db/db.db')
    bodies = db.execute("DELETE FROM bodies WHERE id = ?",body_id)
end

def all_bodies_for_user()
    id = session[:id].to_i
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    db.execute("SELECT * FROM bodies WHERE user_id = ?",id)
end

